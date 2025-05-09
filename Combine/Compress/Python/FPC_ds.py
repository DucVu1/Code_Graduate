def compress_cache_line(cache_line):
    words = [int.from_bytes(cache_line[i*4:(i+1)*4], 'little') for i in range(16)]
    prefixes = []
    data = []
    
    for word in words:
        word_32 = word & 0xFFFFFFFF
        
        # Check for Zero Run (prefix 000)
        if word_32 == 0:
            prefixes.append(0b000)
            data.append((0, 3))
            continue
        
        # Check for 4-bit sign-extended (prefix 001)
        if (word_32 >> 4) in [0, 0xFFFFFFF]:
            val = word_32 & 0xF
            if val == ((val << 28) >> 28) & 0xFFFFFFFF:
                prefixes.append(0b001)
                data.append((val, 4))
                continue
        
        # Check for repeated bytes (prefix 110)
        b = word_32 & 0xFF
        if all((word_32 >> (i * 8)) & 0xFF == b for i in range(4)):
            prefixes.append(0b110)
            data.append((b, 8))
            continue
        
        # Check for 1-byte sign-extended (prefix 010)
        if (word_32 >> 8) in [0, 0xFFFFFF]:
            val = word_32 & 0xFF
            if val == ((val << 24) >> 24) & 0xFFFFFFFF:
                prefixes.append(0b010)
                data.append((val, 8))
                continue
        
        # Check for two halfwords as bytes (prefix 101)
        upper = (word_32 >> 16) & 0xFFFF
        lower = word_32 & 0xFFFF
        if (upper >> 8) in [0, 0xFF] and (lower >> 8) in [0, 0xFF]:
            prefixes.append(0b101)
            combined = ((upper & 0xFF) << 8) | (lower & 0xFF)
            data.append((combined, 16))
            continue
        
        # Check for halfword padded with zero (prefix 100)
        if (word_32 & 0xFFFF) == 0 or (word_32 >> 16) == 0:
            val = (word_32 >> 16) if (word_32 >> 16) != 0 else word_32 & 0xFFFF
            prefixes.append(0b100)
            data.append((val, 16))
            continue
        
        # Check for 16-bit sign-extended (prefix 011)
        val = word_32 & 0xFFFF
        if val == ((val << 16) >> 16) & 0xFFFFFFFF:
            prefixes.append(0b011)
            data.append((val, 16))
            continue
        
        # Uncompressed (prefix 111)
        prefixes.append(0b111)
        data.append((word_32, 32))
    
    # Pack prefixes and data into bytes
    bitstream = []
    for p in prefixes:
        bitstream.extend([(p >> 2) & 1, (p >> 1) & 1, p & 1])
    for d, s in data:
        bitstream.extend([(d >> (s - i - 1)) & 1 for i in range(s)])
    
    # Convert to bytes
    padding = (8 - (len(bitstream) % 8)) % 8
    bitstream += [0] * padding
    compressed = bytes([sum(bit << (7 - j) for j, bit in enumerate(bitstream[i:i+8])) 
                for i in range(0, len(bitstream), 8)])

    # Print compressed bitstream
    print("\nCompressed Bitstream:")
    print("".join(str(b) for b in bitstream))
    
    return compressed

def decompress_cache_line(compressed):
    bitstream = []
    for byte in compressed:
        bitstream.extend([(byte >> (7 - i)) & 1 for i in range(8)])
    
    # Extract prefixes
    prefixes = []
    for i in range(16):
        p = (bitstream[i*3] << 2) | (bitstream[i*3+1] << 1) | bitstream[i*3+2]
        prefixes.append(p)
    
    # Process data
    ptr = 48  # Skip 16*3 prefix bits
    words = []
    for p in prefixes:
        if p == 0b000:  # Zero
            words.append(0)
            ptr += 3
        elif p == 0b001:  # 4-bit
            val = sum(bitstream[ptr + i] << (3 - i) for i in range(4))
            val = val if not (val & 0x8) else val - 16
            words.append(val & 0xFFFFFFFF)
            ptr +=4
        # Other patterns omitted for brevity
        else:  # Uncompressed
            val = sum(bitstream[ptr + i] << (31 - i) for i in range(32))
            words.append(val & 0xFFFFFFFF)
            ptr +=32
    
    # Convert to bytes
    return b''.join(word.to_bytes(4, 'little') for word in words)

# Example usage:
original = b'\x00' * 64  # 64-byte cache line with all zeros
print("Original Data (Hex):")
print(original.hex())

compressed = compress_cache_line(original)
print("\nCompressed Data (Hex):")
print(compressed.hex())

decompressed = decompress_cache_line(compressed)
print("\nDecompressed Data (Hex):")
print(decompressed.hex())

# Verification
print("\nDecompressed matches original:", decompressed == original)
