```markdown
# RPC Node Finder

This script finds available and synchronized RPC nodes for a specified blockchain and outputs them in YAML format.

## Prerequisites

- Python 3.7+
- aiohttp library

## Installation

1. Ensure you have Python 3.7 or higher installed:

```bash
python3 --version
```

2. Install the required library:

```bash
pip install aiohttp
```

If you don't have pip installed, you can install it using:

```bash
sudo apt update
sudo apt install python3-pip
```

## Usage

Run the script using the following command:

```bash
python3 script.py <rpc_url> <chain_id>
```

Where:
- `<rpc_url>` is the URL of the initial RPC server
- `<chain_id>` is the identifier of the blockchain

Example:

```bash
python3 script.py https://story-testnet-rpc.itrocket.net:443 iliad-0
```

## Output

The script outputs a list of synchronized RPC nodes in YAML format. Each entry includes the URL of the RPC node and an `alert_if_down` flag set to `no`.

Example output:

```yaml
      - url: http://176.9.149.220:36657
        alert_if_down: no
      - url: http://82.223.31.166:33557
        alert_if_down: no
      - url: http://65.109.85.166:26057
        alert_if_down: no
      - url: http://141.98.217.86:26657
        alert_if_down: no
      - url: http://148.251.51.140:21557
        alert_if_down: no
      - url: http://38.242.151.189:26657
        alert_if_down: no
      - url: http://65.108.40.171:26657
        alert_if_down: no
      - url: http://116.202.169.185:23357
        alert_if_down: no
      - url: http://65.109.30.106:25257
        alert_if_down: no
```

## Error Handling

If the script fails to fetch data, it will output:

```
Failed to fetch data.
```

If an incorrect number of arguments is provided, it will display the usage instructions:

```
Usage: python script.py <rpc_url> <chain_id>
```

## How It Works

1. The script starts with an initial RPC URL and chain ID.
2. It fetches peer information from the initial RPC.
3. It then fetches peer information from the newly discovered RPCs.
4. This process is repeated once more to discover additional RPCs.
5. The script checks the status of all discovered RPCs.
6. It filters out RPCs that are still catching up with the blockchain.
7. Finally, it outputs the list of available and synchronized RPCs in YAML format.

## Note

This script uses asynchronous programming to efficiently handle multiple network requests. Ensure you're using a Python version that supports async/await syntax (Python 3.7+).
```
