const API_URL = "https://hof.mypinata.cloud/ipfs/QmTZEGW4fzqqVDi3nejSMcMUkReeYp4TT2XMtEXQgU3n9K/"

export async function fetchAPI(path, method, data) {
  const headers = { 'Content-Type': 'application/json' }

  const res = await fetch(API_URL + path, {
    method: method,
    headers,
    body: JSON.stringify(data),
  })

  const json = await res.json()
  if (json.error) {
    console.error(json.error)
    throw new Error(json.error)
  }
  return json
}
