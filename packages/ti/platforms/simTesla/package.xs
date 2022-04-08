/*
 *  Copyright (c) 2016 by Texas Instruments and others.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *      Texas Instruments - initial implementation
 *
 * */

/*
 *  ======== Package.init ========
 *  This function is called when this package is loaded
 */
function init()
{
    this.Platform.$logWarning("This platform is deprecated.  The platform '"
        + "ti.platforms.sdp4430' should be used instead.", this.Platform);
}
/*
 */

