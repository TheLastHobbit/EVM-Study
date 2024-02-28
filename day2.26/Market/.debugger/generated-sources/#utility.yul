{
    { }
    function abi_encode_tuple_t_string_memory_ptr__to_t_string_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        let _1 := 32
        mstore(headStart, _1)
        let length := mload(value0)
        mstore(add(headStart, _1), length)
        let i := 0
        for { } lt(i, length) { i := add(i, _1) }
        {
            mstore(add(add(headStart, i), 64), mload(add(add(value0, i), _1)))
        }
        mstore(add(add(headStart, length), 64), 0)
        tail := add(add(headStart, and(add(length, 31), not(31))), 64)
    }
    function abi_decode_address(offset) -> value
    {
        value := calldataload(offset)
        if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
    }
    function abi_decode_tuple_t_addresst_uint256(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        value1 := calldataload(add(headStart, 32))
    }
    function abi_encode_tuple_t_bool__to_t_bool__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, iszero(iszero(value0)))
    }
    function abi_decode_tuple_t_addresst_addresst_uint256(headStart, dataEnd) -> value0, value1, value2
    {
        if slt(sub(dataEnd, headStart), 96) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        value1 := abi_decode_address(add(headStart, 32))
        value2 := calldataload(add(headStart, 64))
    }
    function abi_encode_tuple_t_uint256__to_t_uint256__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, value0)
    }
    function abi_encode_tuple_t_uint8__to_t_uint8__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, 0xff))
    }
    function abi_decode_tuple_t_address(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
    }
    function panic_error_0x41()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x41)
        revert(0, 0x24)
    }
    function abi_decode_string(offset, end) -> array
    {
        if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
        let _1 := calldataload(offset)
        let _2 := 0xffffffffffffffff
        if gt(_1, _2) { panic_error_0x41() }
        let _3 := not(31)
        let memPtr := mload(64)
        let newFreePtr := add(memPtr, and(add(and(add(_1, 0x1f), _3), 63), _3))
        if or(gt(newFreePtr, _2), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
        mstore(memPtr, _1)
        if gt(add(add(offset, _1), 0x20), end) { revert(0, 0) }
        calldatacopy(add(memPtr, 0x20), add(offset, 0x20), _1)
        mstore(add(add(memPtr, _1), 0x20), 0)
        array := memPtr
    }
    function abi_decode_tuple_t_string_memory_ptrt_string_memory_ptrt_uint256t_uint256(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        let offset := calldataload(headStart)
        let _1 := 0xffffffffffffffff
        if gt(offset, _1) { revert(0, 0) }
        value0 := abi_decode_string(add(headStart, offset), dataEnd)
        let offset_1 := calldataload(add(headStart, 32))
        if gt(offset_1, _1) { revert(0, 0) }
        value1 := abi_decode_string(add(headStart, offset_1), dataEnd)
        value2 := calldataload(add(headStart, 64))
        value3 := calldataload(add(headStart, 96))
    }
    function abi_decode_tuple_t_addresst_address(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := abi_decode_address(headStart)
        value1 := abi_decode_address(add(headStart, 32))
    }
    function extract_byte_array_length(data) -> length
    {
        length := shr(1, data)
        let outOfPlaceEncoding := and(data, 1)
        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
        if eq(outOfPlaceEncoding, lt(length, 32))
        {
            mstore(0, shl(224, 0x4e487b71))
            mstore(4, 0x22)
            revert(0, 0x24)
        }
    }
    function panic_error_0x11()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(0, 0x24)
    }
    function checked_add_t_uint256(x, y) -> sum
    {
        sum := add(x, y)
        if gt(x, sum) { panic_error_0x11() }
    }
    function abi_encode_tuple_t_address_t_uint256_t_uint256__to_t_address_t_uint256_t_uint256__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
        mstore(add(headStart, 32), value1)
        mstore(add(headStart, 64), value2)
    }
    function decrement_t_uint256(value) -> ret
    {
        if iszero(value) { panic_error_0x11() }
        ret := add(value, not(0))
    }
    function abi_encode_tuple_t_address__to_t_address__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
    }
    function array_dataslot_string_storage(ptr) -> data
    {
        mstore(0, ptr)
        data := keccak256(0, 0x20)
    }
    function clean_up_bytearray_end_slots_string_storage(array, len, startIndex)
    {
        if gt(len, 31)
        {
            let _1 := 0
            mstore(_1, array)
            let data := keccak256(_1, 0x20)
            let deleteStart := add(data, shr(5, add(startIndex, 31)))
            if lt(startIndex, 0x20) { deleteStart := data }
            let _2 := add(data, shr(5, add(len, 31)))
            let start := deleteStart
            for { } lt(start, _2) { start := add(start, 1) }
            { sstore(start, _1) }
        }
    }
    function extract_used_part_and_set_length_of_short_byte_array(data, len) -> used
    {
        used := or(and(data, not(shr(shl(3, len), not(0)))), shl(1, len))
    }
    function copy_byte_array_to_storage_from_t_string_memory_ptr_to_t_string_storage(slot, src)
    {
        let newLen := mload(src)
        if gt(newLen, 0xffffffffffffffff) { panic_error_0x41() }
        clean_up_bytearray_end_slots_string_storage(slot, extract_byte_array_length(sload(slot)), newLen)
        let srcOffset := 0
        let srcOffset_1 := 0x20
        srcOffset := srcOffset_1
        switch gt(newLen, 31)
        case 1 {
            let loopEnd := and(newLen, not(31))
            let dstPtr := array_dataslot_string_storage(slot)
            let i := 0
            for { } lt(i, loopEnd) { i := add(i, srcOffset_1) }
            {
                sstore(dstPtr, mload(add(src, srcOffset)))
                dstPtr := add(dstPtr, 1)
                srcOffset := add(srcOffset, srcOffset_1)
            }
            if lt(loopEnd, newLen)
            {
                let lastValue := mload(add(src, srcOffset))
                sstore(dstPtr, and(lastValue, not(shr(and(shl(3, newLen), 248), not(0)))))
            }
            sstore(slot, add(shl(1, newLen), 1))
        }
        default {
            let value := 0
            if newLen
            {
                value := mload(add(src, srcOffset))
            }
            sstore(slot, extract_used_part_and_set_length_of_short_byte_array(value, newLen))
        }
    }
}