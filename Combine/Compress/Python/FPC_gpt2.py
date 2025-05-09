def fpc_compress(words):
    """
    Compresses a list of 32-bit words using the Frequent Pattern Compression (FPC) scheme.
    Each word is encoded with a 3-bit prefix and a compressed data representation.
    """
    compressed_data = []
    prefix_list = []
    
    i = 0
    while i < len(words):
        word = words[i]
        
        # Pattern 000: Zero Run
        if word == 0:
            run_length = 1
            while i + run_length < len(words) and words[i + run_length] == 0 and run_length < 8:
                run_length += 1
            prefix_list.append("000")  # Zero run prefix
            compressed_data.append(run_length)  # Run length (3 bits)
            i += run_length
            continue
        
        # Pattern 001: 4-bit sign-extended
        elif -8 <= word <= 7:
            prefix_list.append("001")
            compressed_data.append(word & 0xF)  # Store 4-bit value
        
        # Pattern 010: 8-bit sign-extended
        elif -128 <= word <= 127:
            prefix_list.append("010")
            compressed_data.append(word & 0xFF)  # Store 8-bit value
        
        # Pattern 011: 16-bit sign-extended
        elif -32768 <= word <= 32767:
            prefix_list.append("011")
            compressed_data.append(word & 0xFFFF)  # Store 16-bit value
        
        # Pattern 100: Halfword padded with zero halfword
        elif (word & 0xFFFF0000) == 0:
            prefix_list.append("100")
            compressed_data.append(word & 0xFFFF)  # Store lower halfword
        
        # Pattern 101: Two halfwords, each sign-extended byte
        elif (word & 0xFF00FF00) == 0:
            prefix_list.append("101")
            compressed_data.append((word & 0xFF) | ((word >> 8) & 0xFF))
        
        # Pattern 110: Word consisting of repeated bytes
        elif (word & 0xFF) == ((word >> 8) & 0xFF) == ((word >> 16) & 0xFF) == ((word >> 24) & 0xFF):
            prefix_list.append("110")
            compressed_data.append(word & 0xFF)  # Store single byte
        
        # Pattern 111: Uncompressed word
        else:
            prefix_list.append("111")
            compressed_data.append(word)  # Store full 32-bit word
        
        i += 1
    
    return prefix_list, compressed_data


# Example usage:
test_words = [0, 0, 0, 5, 128, 32768, 0x00FF00FF, 42, 0, 0]
prefixes, compressed = fpc_compress(test_words)

# Display results
print("Prefixes:", prefixes)
print("Compressed Data:", compressed)
