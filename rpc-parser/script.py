import aiohttp
import asyncio

class AioHttpCalls:
    def __init__(self, rpc: str, chain_id: str, timeout: int = 3):
        self.rpc = rpc
        self.chain_id = chain_id
        self.timeout = timeout
        self.session = None

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        await self.session.close()

    async def handle_request(self, url, callback):
        try:
            async with self.session.get(url, timeout=self.timeout) as response:
                if 200 <= response.status < 300:
                    data = await response.json()
                    return await callback(data)
        except Exception:
            return None

    async def fetch_rpc(self, rpc_url):
        async def process_response(response):
            return [
                f"http://{rpc['remote_ip']}:{rpc['node_info']['other']['rpc_address'].split(':')[-1]}"
                for rpc in response['result']['peers']
                if rpc['node_info']['network'] == self.chain_id and 'tcp://127' not in rpc['node_info']['other']['rpc_address']
            ]
        return await self.handle_request(f"{rpc_url}/net_info", process_response)

    async def fetch_rpc_metrics(self, rpc_url):
        async def process_response(response):
            sync_info = response['result']['sync_info']
            return {
                "rpc_url": rpc_url,
                "catching_up": sync_info['catching_up']
            }
        return await self.handle_request(f"{rpc_url}/status", process_response)

    async def get_new_rpc(self, rpc_arr: list):
        if not rpc_arr:
            return []
        tasks = [self.fetch_rpc(rpc) for rpc in rpc_arr]
        results = await asyncio.gather(*tasks)
        return list({endpoint for sublist in results if sublist for endpoint in sublist})

async def fetch_available_rpc(rpc, chain_id):
    async with AioHttpCalls(rpc=rpc, chain_id=chain_id) as session:
        initial_rpc = await session.fetch_rpc(rpc)
        if not initial_rpc:
            return []
        second_rpc = await session.get_new_rpc(initial_rpc)
        third_rpc = await session.get_new_rpc(second_rpc)
        rpc_sum = list(set(initial_rpc + second_rpc + third_rpc))
        metrics = await asyncio.gather(*(session.fetch_rpc_metrics(rpc) for rpc in rpc_sum))
        return [rpc for rpc in metrics if rpc and not rpc["catching_up"]]

def print_output_yaml(rpc_urls):
    yaml_output = "\n".join(f"      - url: {rpc['rpc_url']}\n        alert_if_down: no" for rpc in rpc_urls)
    print(yaml_output)

async def main(rpc, chain_id):
    result = await fetch_available_rpc(rpc, chain_id)
    if result:
        print_output_yaml(result)
    else:
        print("Failed to fetch data.")

if __name__ == '__main__':
    import sys
    if len(sys.argv) == 3:
        asyncio.run(main(sys.argv[1], sys.argv[2]))
    else:
        print("Usage: python script.py <rpc_url> <chain_id>")
