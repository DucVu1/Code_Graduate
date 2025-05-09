import sys

class CPackCompressor:
    PATTERNS = {
        'zzzz': 0b00,   # All zero bytes
        'xxxx': 0b01,   # Fully uncompressed
        'mmmm': 0b10,   # Matches dictionary
        'mmxx': 0b1100, # First two bytes match dictionary
        'zzzx': 0b1101, # Three zero bytes, one different byte
        'mmmx': 0b1110  # Three bytes match dictionary, one different
    }

    def __init__(self):
        self.dictionary = []  # Store recently seen words
    
    def compress(self, data):
        if len(data) != 64:
            raise ValueError("Input must be 64-byte cache line")

        words = [int.from_bytes(data[i*4:(i+1)*4], 'little') for i in range(16)]
        metadata = []
        compressed = []
        bitstream = []

        print("\n[Compression Debug Info]")
        print("{:<5} {:<12} {:<12} {:<12} {:<10}".format("Idx", "Original", "Pattern", "Compressed", "Size (bits)"))
        print("="*55)
        
        for i, word in enumerate(words):
            pattern, value, size = self._find_best_pattern(word)
            metadata.append((pattern, size))
            compressed.append(value)
            pattern_name = [k for k, v in self.PATTERNS.items() if v == pattern][0]
            
            print(f"{i:<5} {word:#010x} {pattern_name:<12} {value:#010x} {size:<10}")

        # Generate header (2-4 bits per pattern)
        for pattern, _ in metadata:
            pattern_bits = bin(pattern)[2:].zfill(4)  # Convert pattern to bits
            bitstream.extend([int(b) for b in pattern_bits])
        
        # Pack compressed data
        for (pattern, size), value in zip(metadata, compressed):
            if size > 0:
                bits = [(value >> (size-1-i)) & 1 for i in range(size)]
                bitstream.extend(bits)
        
        # Pad bits to byte alignment
        pad_bits = (8 - (len(bitstream) % 8)) % 8
        bitstream += [0] * pad_bits
        
        compressed_bytes = bytes(
            int(''.join(map(str, bitstream[i:i+8])), 2)
            for i in range(0, len(bitstream), 8)
        )
        
        print("\nCompressed Bitstream:")
        print(' '.join(f'{b:08b}' for b in compressed_bytes))
        
        return compressed_bytes, metadata

    def _find_best_pattern(self, word):
        word_bytes = word.to_bytes(4, 'little')
        
        if word == 0:
            return self.PATTERNS['zzzz'], 0, 0  # All zero
        
        if word in self.dictionary:
            return self.PATTERNS['mmmm'], self.dictionary.index(word), 6  # Matches dictionary (6-bit index)
        
        self.dictionary.append(word)
        if len(self.dictionary) > 8:
            self.dictionary.pop(0)
        
        if word_bytes[1:] == b'\x00\x00\x00':
            return self.PATTERNS['zzzx'], word_bytes[0], 8  # Last 3 bytes zero
        
        if word_bytes[2:] == b'\x00\x00':
            return self.PATTERNS['mmxx'], int.from_bytes(word_bytes[:2], 'little'), 16  # First 2 match dictionary
        
        if word_bytes[3:] == b'\x00':
            return self.PATTERNS['mmmx'], int.from_bytes(word_bytes[:3], 'little'), 24  # First 3 match dictionary
        
        return self.PATTERNS['xxxx'], word, 32  # Fully uncompressed


def test_compression():
    original = bytearray()
    
    # Test cases
    original.extend(b'\x00' * 4)  # Zero word
    original.extend(b'\xAB\x00\x00\x00')  # zzzx pattern
    original.extend(b'\x12\x34\x00\x00')  # mmxx pattern
    original.extend(b'\x56\x78\x9A\x00')  # mmmx pattern
    original.extend(b'\x01\x02\x03\x04')  # Uncompressed
    
    # Fill remaining with zeros
    original.extend(b'\x00' * (64 - len(original)))
    
    compressor = CPackCompressor()
    compressed, metadata = compressor.compress(original)
    
    print("\nOriginal Data (Hex):")
    print(original.hex().upper())
    
    print("\nCompressed Data (Hex):")
    print(compressed.hex().upper())

    print("\nOriginal size:", len(original), "bytes")
    print("Compressed size:", len(compressed), "bytes")
    print("Compression ratio:", f"{len(compressed)/len(original)*100:.1f}%")
    
    print("\nCompression Patterns:")
    patterns = {v: k for k, v in compressor.PATTERNS.items()}
    for i, (pattern, size) in enumerate(metadata):
        print(f"Word {i:2}: {patterns[pattern]:12} | Size: {size} bits")

if __name__ == "__main__":
    test_compression()
