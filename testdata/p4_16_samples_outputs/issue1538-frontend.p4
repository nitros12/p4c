#include <core.p4>
#define V1MODEL_VERSION 20180101
#include <v1model.p4>

struct metadata {
    bit<16> tmp_port;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

struct headers {
    ethernet_t ethernet;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("ParserImpl.tmp_port") bit<16> tmp_port_0;
    state start {
        {
            @name("ParserImpl.x_1") bit<16> x_0 = (bit<16>)standard_metadata.ingress_port;
            @name("ParserImpl.hasReturned") bool hasReturned = false;
            @name("ParserImpl.retval") bit<16> retval;
            hasReturned = true;
            retval = x_0 + 16w1;
            tmp_port_0 = retval;
        }
        transition start_0;
    }
    state start_0 {
        packet.extract<ethernet_t>(hdr.ethernet);
        {
            @name("ParserImpl.x_2") bit<16> x_1 = hdr.ethernet.etherType;
            @name("ParserImpl.hasReturned") bool hasReturned_0 = false;
            @name("ParserImpl.retval") bit<16> retval_0;
            hasReturned_0 = true;
            retval_0 = x_1 + 16w1;
            hdr.ethernet.etherType = retval_0;
        }
        meta.tmp_port = tmp_port_0;
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".my_drop") action my_drop(inout standard_metadata_t smeta) {
        mark_to_drop(smeta);
    }
    @name("ingress.set_port") action set_port(bit<9> output_port) {
        standard_metadata.egress_spec = output_port;
    }
    @name("ingress.mac_da") table mac_da_0 {
        key = {
            hdr.ethernet.dstAddr: exact @name("hdr.ethernet.dstAddr") ;
        }
        actions = {
            set_port();
            my_drop(standard_metadata);
        }
        default_action = my_drop(standard_metadata);
    }
    apply {
        mac_da_0.apply();
        {
            @name("ingress.x_3") bit<16> x_2 = hdr.ethernet.srcAddr[15:0];
            @name("ingress.hasReturned_0") bool hasReturned_3 = false;
            @name("ingress.retval_0") bit<16> retval_3;
            @name("ingress.tmp") bit<16> tmp;
            @name("ingress.tmp_0") bit<16> tmp_0;
            @name("ingress.tmp_1") bit<16> tmp_1;
            tmp = x_2;
            {
                @name("ingress.x_0") bit<16> x_3 = x_2;
                @name("ingress.hasReturned") bool hasReturned_4 = false;
                @name("ingress.retval") bit<16> retval_4;
                hasReturned_4 = true;
                retval_4 = x_3 + 16w1;
                tmp_0 = retval_4;
            }
            tmp_1 = tmp + tmp_0;
            hasReturned_3 = true;
            retval_3 = tmp_1;
            hdr.ethernet.srcAddr[15:0] = retval_3;
        }
        {
            @name("ingress.x_4") bit<16> x_4 = hdr.ethernet.srcAddr[15:0];
            @name("ingress.hasReturned") bool hasReturned_5 = false;
            @name("ingress.retval") bit<16> retval_5;
            hasReturned_5 = true;
            retval_5 = x_4 + 16w1;
            hdr.ethernet.srcAddr[15:0] = retval_5;
        }
        {
            @name("ingress.x_5") bit<16> x_5 = hdr.ethernet.etherType;
            @name("ingress.hasReturned") bool hasReturned_6 = false;
            @name("ingress.retval") bit<16> retval_6;
            hasReturned_6 = true;
            retval_6 = x_5 + 16w1;
            hdr.ethernet.etherType = retval_6;
        }
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

