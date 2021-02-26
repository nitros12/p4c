/* Automatically generated by p4c-ubpf from backends/ubpf/examples/port-forwarding.p4 on Wed Feb 24 15:31:04 2021
 */
#ifndef _P4_GEN_HEADER_
#define _P4_GEN_HEADER_
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "ubpf_common.h"


enum ubpf_action{
ABORT,
DROP,
PASS,
REDIRECT,
};

struct standard_metadata {
    uint32_t input_port; /* bit<32> */
    uint32_t packet_length; /* bit<32> */
    enum ubpf_action output_action; /* ubpf_action */
    uint32_t output_port; /* bit<32> */
    uint8_t clone; /* bool */
    uint32_t clone_port; /* bit<32> */
};

struct Ethernet_h {
    uint64_t dstAddr; /* EthernetAddress */
    uint64_t srcAddr; /* EthernetAddress */
    uint16_t etherType; /* bit<16> */
    uint8_t ebpf_valid;
};

struct IPv4_h {
    uint8_t version; /* bit<4> */
    uint8_t ihl; /* bit<4> */
    uint8_t diffserv; /* bit<8> */
    uint16_t totalLen; /* bit<16> */
    uint16_t identification; /* bit<16> */
    uint8_t flags; /* bit<3> */
    uint16_t fragOffset; /* bit<13> */
    uint8_t ttl; /* bit<8> */
    uint8_t protocol; /* bit<8> */
    uint16_t hdrChecksum; /* bit<16> */
    uint32_t srcAddr; /* IPv4Address */
    uint32_t dstAddr; /* IPv4Address */
    uint8_t ebpf_valid;
};

struct Headers_t {
    struct Ethernet_h ethernet; /* Ethernet_h */
    struct IPv4_h ipv4; /* IPv4_h */
};

struct metadata {
};


enum ubpf_map_type {
    UBPF_MAP_TYPE_ARRAY = 1,
    UBPF_MAP_TYPE_HASHMAP = 4,
    UBPF_MAP_TYPE_LPM_TRIE = 5,
};
struct ubpf_map_def {
    enum ubpf_map_type type;
    unsigned int key_size;
    unsigned int value_size;
    unsigned int max_entries;
    unsigned int nb_hash_functions;
};

struct pipe_test_tbl_key {
    uint32_t std_meta_input_port; /* std_meta.input_port */
};
enum test_tbl_0_actions {
    pipe_mod_nw_tos,
    pipe_test_tbl_NoAction,
};
struct pipe_test_tbl_value {
    enum test_tbl_0_actions action;
    union {
        struct {
            uint32_t out_port;
        } pipe_mod_nw_tos;
        struct {
        } pipe_test_tbl_NoAction;
    } u;
};
#if CONTROL_PLANE
static void init_tables() 
{
    uint32_t ebpf_zero = 0;
    {
        struct pipe_test_tbl_value pipe_test_tbl_NoAction_value = {
            .action = pipe_test_tbl_NoAction,
            .u = {.pipe_test_tbl_NoAction = {}},
        };
        INIT_UBPF_TABLE("pipe_test_tbl_defaultAction", sizeof(ebpf_zero), sizeof(pipe_test_tbl_NoAction_value));
        ubpf_map_update(&pipe_test_tbl_defaultAction, &ebpf_zero, &pipe_test_tbl_NoAction_value);
    }
}
#endif
#endif