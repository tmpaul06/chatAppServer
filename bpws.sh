#!/bin/bash
 case "$1" in
    a | attach ) rel/bpws/bin/bpws attach;;
    b | build ) rebar compile generate;;
    cy | cycle ) rel/bpws/bin/bpws stop ;rebar compile generate ;rel/bpws/bin/bpws start; sleep 3; rel/bpws/bin/bpws attach;;
    c | compile ) rebar compile;;
    g | generate ) rebar generate;;
    s | start ) rel/bpws/bin/bpws start;;
    q | stop ) rel/bpws/bin/bpws stop;;
    * ) ;;
 esac
