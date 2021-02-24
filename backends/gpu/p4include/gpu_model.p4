#ifndef _GPU_MODEL_P4_
#define _GPU_MODEL_P4_

#include <core.p4>

enum gpu_action {
    DROP,
    PASS,
    REDIRECT
}

struct standard_metadata {
    bit<32>     input_port;
    bit<32>     packet_length;
    gpu_action output_action;
    bit<32>     output_port;
}


/*
 * Architecture.
 *
 * M must be a struct.
 *
 * H must be a struct where every one of its members is of type
 * header, header stack, or header_union.
 */

parser parse<H, M>(packet_in packet, out H headers, inout M meta, inout standard_metadata std);

control pipeline<H, M>(inout H headers, inout M meta, inout standard_metadata std);

/*
 * The only legal statements in the body of the deparser control are:
 * calls to the packet_out.emit() method.
 */
@deparser
control deparser<H>(packet_out b, in H headers);

package gpu<H, M>(parse<H, M> prs,
                  pipeline<H, M> p,
                  deparser<H> dprs);

#endif /* _GPU_MODEL_P4_ */
