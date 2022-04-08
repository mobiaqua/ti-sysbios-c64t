/*
 * Copyright (c) 2016, Texas Instruments Incorporated
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * *  Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * *  Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * *  Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 *  ======== mqueue.c ========
 */

#include <xdc/std.h>
#include <xdc/runtime/Error.h>
#include <xdc/runtime/Memory.h>

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <ti/sysbios/BIOS.h>
#include <ti/sysbios/knl/Clock.h>
#include <ti/sysbios/knl/Task.h>
#include <ti/sysbios/knl/Mailbox.h>

#include <ti/sysbios/posix/pthread.h>
#include <ti/sysbios/posix/mqueue.h>
#include <ti/sysbios/posix/_pthread_error.h>

/*
 *  ======== MQueueObj ========
 */
typedef struct MQueueObj {
    struct MQueueObj  *next;
    struct MQueueObj  *prev;
    Mailbox_Handle     mailbox;
    mq_attr            attrs;
    int                refCount;
    char              *name;
} MQueueObj;

static MQueueObj *findInList(const char *name);

MQueueObj *mqList = NULL;

/*
 *  ======== mq_close ========
 */
int mq_close(mqd_t desc)
{
    MQueueObj *msgQueue = (MQueueObj *)desc;
    MQueueObj *nextMQ, *prevMQ;
    UInt               key;

    key = Task_disable();

    msgQueue->refCount--;

    if (msgQueue->refCount == 0) {
        /* If the message queue is in the list, remove it. */
        if (mqList == msgQueue) {
            mqList = msgQueue->next;
        }
        else {
            prevMQ = msgQueue->prev;
            nextMQ = msgQueue->next;

            if (prevMQ) {
                prevMQ->next = nextMQ;
            }
            if (nextMQ) {
                nextMQ->prev = prevMQ;
            }
        }

        msgQueue->next = msgQueue->prev = NULL;

        if (msgQueue->mailbox != NULL) {
            Mailbox_delete(&msgQueue->mailbox);
        }

        if (msgQueue->name != NULL) {
            Memory_free(Task_Object_heap(), msgQueue->name,
                    strlen(msgQueue->name) + 1);
        }

        Memory_free(Task_Object_heap(), msgQueue, sizeof(MQueueObj));
    }

    Task_restore(key);

    return (0);
}

/*
 *  ======== mq_getattr ========
 */
int mq_getattr(mqd_t desc, struct mq_attr *pAttrs)
{
    MQueueObj *msgQueue = (MQueueObj *)desc;

    *pAttrs = msgQueue->attrs;

    return (0);
}

/*
 *  ======== mq_notify ========
 */
int mq_notify(mqd_t desc, const struct sigevent *pEvt)
{
//    MQueueObj *msgQueue = (MQueueObj *)desc;

    // TODO
    return (0);
}

/*
 *  ======== mq_open ========
 */
mqd_t mq_open(const char *name, int flags, ...)
{
    va_list           va;
    mode_t            mode;
    mq_attr          *attrs = NULL;
    MQueueObj        *msgQueue = (MQueueObj *)(-1);
    MQueueObj        *mq;
    Error_Block       eb;
    UInt              key;


    va_start(va, flags);

    if (flags & O_CREAT) {
        mode = va_arg(va, mode_t);
        attrs = va_arg(va, mq_attr*);
    }
    va_end(va);

    Error_init(&eb);

    key = Task_disable();

    mq = findInList(name);

    if ((mq != NULL) & (flags & O_CREAT) & (flags & O_EXCL)) {
        /* Error: Message queue has alreadey been opened and O_EXCL is set */
        goto done;
    }

    if ((mq == NULL) && !(flags & O_CREAT)) {
        /* Error: Message has not been opened and O_CREAT is not set */
        goto done;
    }

    if (mq == NULL) {
        if ((attrs == NULL) || (attrs->mq_maxmsg <= 0) ||
                (attrs->mq_msgsize <= 0)) {
            goto done;
        }

        /* Allocate the MQueueObj */
        msgQueue = (MQueueObj *)Memory_alloc(Task_Object_heap(),
                sizeof(MQueueObj), 0, &eb);
        if (msgQueue == NULL) {
            goto done;
        }

        msgQueue->refCount = 1;

        msgQueue->name = NULL;
        msgQueue->attrs = *attrs;

        /*
         *  Add the message queue to the list now, so that in case of
         *  failure we can call mq_close()
         */
        msgQueue->prev = NULL;

        if (mqList != NULL) {
            mqList->prev = msgQueue;
        }
        msgQueue->next = mqList;
        mqList = msgQueue;

        msgQueue->mailbox = Mailbox_create(attrs->mq_msgsize,
                attrs->mq_maxmsg, NULL, NULL);

        if (msgQueue->mailbox == NULL) {
            mq_close((mqd_t)msgQueue);
            goto done;
        }

        msgQueue->name = (char *)Memory_alloc(Task_Object_heap(),
                strlen(name) + 1, 0, &eb);

        if (msgQueue->name == NULL) {
            mq_close((mqd_t)msgQueue);
            goto done;
        }

        strcpy(msgQueue->name, name);
    }
    else {
        msgQueue = mq;
        mq->refCount++;
    }

done:
    Task_restore(key);

    (void)mode;

    return ((mqd_t)msgQueue);
}

/*
 *  ======== mq_receive ========
 *  On success, returns the number of bytes in the message.  On failure,
 *  returns -1 and sets errno to the appropriate error.
 */
long mq_receive(mqd_t desc, char *msg, size_t msgLen, unsigned *msgPrio)
{
    MQueueObj  *msgQueue = (MQueueObj *)desc;
    int         retVal = -1;

    /* Wait forever to receive a message */
    if (Mailbox_pend(msgQueue->mailbox, (Ptr)msg, BIOS_WAIT_FOREVER)) {
        retVal = (msgQueue->attrs).mq_msgsize;
    }

    return (retVal);
}

/*
 *  ======== mq_send ========
 */
int mq_send(mqd_t desc, const char *msg, size_t msgLen, unsigned msgPrio)
{
    MQueueObj *msgQueue = (MQueueObj *)desc;

    /* Wait forever to send a message */
    Mailbox_post(msgQueue->mailbox, (Ptr)msg, BIOS_WAIT_FOREVER);

    return (0);
}

/*
 *  ======== mq_setattr ========
 */
int mq_setattr(mqd_t desc, const struct mq_attr * /*restrict */ pAttrs,
        struct mq_attr * /* restrict */ pOldAttrs)
{
    MQueueObj *msgQueue = (MQueueObj *)desc;
    UInt       key;
    long       flags;

    /*
     *  The message queue attributes corresponding to the following
     *  members defined in the mq_attr structure shall be set to the
     *  specified values upon successful completion of mq_setattr():
     *  mq_flags
     *        The value of this member is the bitwise-logical OR of
     *        zero or more of O_NONBLOCK and any implementation-defined flags.
     *
     *  The values of the mq_maxmsg, mq_msgsize, and mq_curmsgs members of
     *  the mq_attr structure shall be ignored by mq_setattr().
    */
    key = Task_disable();

    flags = (msgQueue->attrs).mq_flags;
    if (pOldAttrs != NULL) {
        *pOldAttrs = msgQueue->attrs;
    }

    flags = (flags & ~ O_NONBLOCK) | (pAttrs->mq_flags & O_NONBLOCK);
    (msgQueue->attrs).mq_flags = flags;

    Task_restore(key);

    return (0);
}

/*
 *  ======== mq_timedreceive ========
 */
long mq_timedreceive(mqd_t desc, char *msg, size_t msgLen,
        unsigned *msgPrio, const struct timespec *ts)
{
    MQueueObj          *msgQueue = (MQueueObj *)desc;
    struct timespec     curtime;
    UInt32              timeout;
    long                usecs = 0;
    time_t              secs = 0;
    int                 retVal = -1;

    if ((ts->tv_nsec < 0) || (1000000000 < ts->tv_nsec)) {
        return (EINVAL);
    }

    clock_gettime(0, &curtime);
    secs = ts->tv_sec - curtime.tv_sec;

    if ((ts->tv_sec < curtime.tv_sec) ||
            ((secs == 0) && (ts->tv_nsec <= curtime.tv_nsec))) {
        timeout = 0;
    }
    else {
        usecs = (ts->tv_nsec - curtime.tv_nsec) / 1000;

        if (usecs < 0) {
            usecs += 1000000;
            secs--;
        }
        usecs += secs * 1000000;
        timeout = usecs / Clock_tickPeriod;
    }

    /* Wait forever to receive a message */
    if (Mailbox_pend(msgQueue->mailbox, (Ptr)msg, timeout)) {
        retVal = (msgQueue->attrs).mq_msgsize;
    }

    return (retVal);
}

/*
 *  ======== mq_timedsend ========
 */
int mq_timedsend(mqd_t desc, const char *msg, size_t msgLen,
        unsigned msgPrio, const struct timespec *ts)
{
    MQueueObj          *msgQueue = (MQueueObj *)desc;
    struct timespec     curtime;
    UInt32              timeout;
    long                usecs = 0;
    time_t              secs = 0;
    int                 retVal = 0;

    if ((ts->tv_nsec < 0) || (1000000000 < ts->tv_nsec)) {
        return (EINVAL);
    }

    clock_gettime(0, &curtime);
    secs = ts->tv_sec - curtime.tv_sec;

    if ((ts->tv_sec < curtime.tv_sec) ||
            ((secs == 0) && (ts->tv_nsec <= curtime.tv_nsec))) {
        timeout = 0;
    }
    else {
        usecs = (ts->tv_nsec - curtime.tv_nsec) / 1000;

        if (usecs < 0) {
            usecs += 1000000;
            secs--;
        }
        usecs += secs * 1000000;
        timeout = usecs / Clock_tickPeriod;
    }


    /* Wait for timeout to send a message */
    if (!Mailbox_post(msgQueue->mailbox, (Ptr)msg, timeout)) {
        retVal = -1;
    }

    return (retVal);
}

/*
 *  ======== mq_unlink ========
 */
int mq_unlink(const char *name)
{
    return (0);
}


/*
 *************************************************************************
 *                      Internal functions
 *************************************************************************
 */

/*
 *  ======== findInList ========
 */
static MQueueObj *findInList(const char *name)
{
    MQueueObj *mq;

    mq = mqList;

    while (mq != NULL) {
        if (strcmp(mq->name, name) == 0) {
            return (mq);
        }
        mq = mq->next;
    }

    return (NULL);
}
