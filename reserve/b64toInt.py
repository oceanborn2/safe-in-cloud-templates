import base64
from datetime import datetime

class Main:
    def __init__(self):
        pass

    def run(self):
        # Example base64 string (for Unix timestamp 1718995200)
        b64_str = "gn552g4AAAA=" # a datetime integer encoded as base64

        # Step 1: Base64 decode to bytes
        bytes_data = base64.b64decode(b64_str)

        # Step 2: Bytes to integer (big-endian)
        timestamp = int.from_bytes(bytes_data, byteorder='big')

        # Step 3: Integer to datetime
        dt = datetime.utcfromtimestamp(timestamp)

        print("Integer:", timestamp)
        print("Datetime:", dt)

if __name__ == '__main__':
    Main().run()
