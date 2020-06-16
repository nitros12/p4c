// define globals
(defm local_metadata (struct local_metadata_t))
(defv wcmp_group_id_valid (bit 1))
(defv wcmp_group_id_value (bit 12))
(defv nexthop_id_valid (bit 1))
(defv nexthop_id_value (bit 10))
(defv router_interface_id_valid (bit 1))
(defv route_interface_id_value (bit 10))
(defv neighbor_id_valid (bit 1))
(defv neighbor_id_value (bit 10))
(defv HASH_BASE_CRC16 (bit 1))
(defv HASH_MAX_CRC16 (bit 14))
(defv wcmp_selector_input (bit 16))

// define header format
(header ethernet_t
 (field dst_addr (bit 48))
 (field src_addr (bit 48))
 (field ether_type (bit 16)))
(header ipv4_t
 (field version (bit 4))
 (field ihl (bit 4))
 (field dscp (bit 6))
 (field ecn (bit 2))
 (field total_len (bit 16))
 (field identification (bit 16))
 (field flags (bit 3))
 (field frag_offset (bit 13))
 (field ttl (bit 8))
 (field protocol (bit 8))
 (field header_checksum (bit 16))
 (field src_addr (bit 32))
 (field dst_addr (bit 32)))
(header ipv6_t
 (field version (bit 4))
 (field dscp (bit 6))
 (field ecn (bit 2))
 (field flow_label (bit 20))
 (field payload_length (bit 16))
 (field next_header (bit 8))
 (field hop_limit (bit 8))
 (field src_addr (bit 128))
 (field dst_addr (bit 128)))
(header udp_t
 (field src_port (bit 16))
 (field dst_port (bit 16))
 (field hdr_length (bit 16))
 (field checksum (bit 16)))
(header tcp_t
 (field src_port (bit 16))
 (field dst_port (bit 16))
 (field seq_no (bit 32))
 (field ack_no (bit 32))
 (field data_offset (bit 4))
 (field res (bit 4))
 (field flags (bit 8))
 (field window (bit 16))
 (field checksum (bit 16))
 (field urgent_ptr (bit 16)))
(header icmp_t
 (field type (bit 8))
 (field code (bit 8))
 (field checksum (bit 16)))
(header arp_t
 (field hw_type (bit 16))
 (field proto_type (bit 16))
 (field hw_addr_len (bit 8))
 (field proto_addr_len (bit 8))
 (field opcode (bit 16))
 (field sender_hw_addr (bit 48))
 (field sender_proto_addr (bit 32))
 (field target_hw_addr (bit 48))
 (field target_proto_addr (bit 32)))
(header packet_in_header_t
 (field ingress_port (bit 32))
 (field target_egress_port (bit 32)))
(header packet_out_header_t
 (field egress_port (bit 32))
 (field submit_to_ingress (bit 1))
 (field unused_pad (bit 7)))

// define structs
(struct headers_t
 (field ethernet ethernet_t)
 (field ipv4 ipv4_t)
 (field ipv6 ipv6_t)
 (field icmp icmp_t)
 (field tcp tcp_t)
 (field udp udp_t)
 (field arp arp_t))
(struct local_metadata_t
 (field vrf_id (bit 10))
 (field l4_src_port (bit 16))
 (field l4_dst_port (bit 16)))

//define enum
(enum parser_error
 (declare type (bit 8))
 ((UnhandledIPv4Options 1)
  (BadIPv4HeaderChecksum 2)))

// define actions and tables. TODO: resolve name conflict
(defa set_dst_mac
 ((mov headers.ethernet.dst_addr dst_mac)))
(deft neighboar_table
 (actions (set_dst_mac NoAction))
 (default_action NoAction)
 (key router_interface_id_value exact)
 (key neighbor_id_vlaue exact))
(defa set_port_and_src_mac
 ((mov headers.ethernet.src_addr src_mac)))
(deft router_interface_table
 (key router_interface_id_value exact)
 (actions (set_port_and_src_mac NoAction))
 (default_action NoAction))
(defa set_nexthop
 ((mov router_interface_id_value true)
  (mov router_interface_id_value router_interface_id)
  (mov neighbor_id_valid true)
  (mov neighbor_id_value neighbor_id)))
(deft nexthop_table
 (key nexthop_id_value exact)
 (actions (set_nexthop NoAction))
 (default_action NoAction))
(defa set_nexthop_id
 ((mov nexthop_id_valid true)
  (mov nexthop_id_value nexthop_id)))
(deft wcmp_group_table
 (key wcmp_group_id_value exact)
 (key wcmp_selector_input selector)
 (actions (set_nexthop_id NoAction))
 (default_action NoAction))
(defa drop ())
(defa set_wcmp_group_id
 ((mov wcmp_group_id_valid true)
  (mov wcmp_group_id_value wcmp_group_id)))
(deft ipv4_table
 (key local_metadata.vrf_id exact)
 (key headers.ipv4.dst_addr lpm)
 (actions (drop set_nexthop_id set_wcmp_group_id))
 (default_action drop))
(deft ipv6_table
 (key local_metadata.vrf_id exact)
 (key headers.ipv6.dst_addr lpm)
 (actions (drop set_nexthop_id set_wcmp_group_id)))

 //define control flow, ingress and egress will be squashed together
(defc 
  (apply acl_set_vrf_set_vrt_table)
  (mov routing_wcmp_group_id_valid false)
  (mov routing_nexthop_id_valid false)
  (mov routing_router_interface_id_valid false)
  (mov routing_neighbor_id_valid false)
  (mov routing_wcmp_selector_input 0)
  (jmpv lbl_0 headers.ipv4)
  (jmpv lbl_1 headers.ipv6)
  (label lbl_0)
  (mov wcmp_selector_input
   (call get_hash
    (headers.ipv4.dst_addr, headers.ipv4.src_addr,
     local_metadata.l4_src_port, local_metadata.l4_dst_port)))
  (jmp lbl_2)
  (label lbl_1)
  (mov wcmp_selector_input
   (call get_hash
    (headers.ipv6.dst_addr, headers.ipv6.src_addr,
     (slice headers.ipv6.flow_label 15 0), local_metadata.l4_src_port,
     local_metadata.l4_dst_port)))
  (apply ipv6_table)
  (label lbl_2)
  (jmp (not wcmp_group_id_valid) lbl_3)
  (apply wcmp_group_table)
  (label lbl_3)
  (jmp (not nexthop_id_valid) lbl_4)
  (apply nexthop_table)
  (jmp (not (and router_interface_id_valid neighbor_id_valid)) lbl_4)
  (apply router_interface_table)
  (apply neighbor_tabl)
  (label lbl_4)
  (jmpv lbl_5 headers.ipv4)
  (jmp lbl_6)
  (label lbl_5)
  (le tmp_0 headers.ipv4.ttl 1)
  (jmp tmp_0 lbl_6)
  (add tmp_1 headers.ipv4.ttl 255)
  (mov headers.ipv4.ttl tmp_1)
  (label lbl_6)
  (jmpv lbl_8 headers.ipv6)
  (jmp lbl_9)
  (label lbl_8)
  (le tmp_2 headers.ipv6.hop_limit 1)
  (jmp tmp_2 lbl_9)
  (add tmp_3 headers.ipv6.hop_limit 255)
  (mov headers.ipv6.hop_limit tmp_3)
  (label lbl_9)
  (emit headers.ethernet)
  (emit headers.ipv4)
  (emit headers.ipv6)
  (emit headers.arp)
  (emit headers.icmp)
  (emit headers.tcp)
  (emit headers.udp)
)
