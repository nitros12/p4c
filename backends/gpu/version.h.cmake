#ifndef _BACKENDS_GPU_VERSION_H
#define _BACKENDS_GPU_VERSION_H

/**
Set the compiler version at build time.
The build system defines P4C_VERSION as a full string as well as the
following components: P4C_VERSION_MAJOR, P4C_VERSION_MINOR,
P4C_VERSION_PATCH, P4C_VERSION_RC, and P4C_GIT_SHA.

They can be used to construct a version string as follows:
#define VERSION_STRING "@P4C_VERSION@"
or
#define VERSION_STRING "@P4C_VERSION_MAJOR@.@P4C_VERSION_MINOR@.@P4C_VERSION_PATCH@@P4C_VERSION_RC@"

Or, since this is backend specific, feel free to define other numbering
scheme.

*/

#define P4C_GPU_VERSION_STRING "@P4C_VERSION@"

#endif  // _BACKENDS_GPU_VERSION_H
