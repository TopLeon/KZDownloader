use crate::frb_generated::StreamSink;
use flutter_rust_bridge::frb;
use wreq::{Client, header};
use wreq_util::Emulation;
use futures::StreamExt;
use std::collections::HashMap;
use wreq::redirect::Policy;

// Get initial information with a HEAD request
pub async fn get_head_info_rust(url: String, headers: HashMap<String, String>) -> anyhow::Result<HashMap<String, String>> {
    // Configure the client
    let client = Client::builder()
        .emulation(Emulation::Chrome130)
        .build()?;

    // Setup headers
    let mut header_map = header::HeaderMap::new();
    if !headers.is_empty() {
        for (k, v) in headers {
            if k.eq_ignore_ascii_case("host") { continue; }

            let k_name = header::HeaderName::from_bytes(k.as_bytes()).map_err(|e| anyhow::anyhow!("Header key invalido: {} ({})", k, e))?;
            let v_val = header::HeaderValue::from_str(&v).map_err(|e| anyhow::anyhow!("Header value invalido: {} ({})", v, e))?;
            header_map.insert(k_name, v_val);
        }
    }

    // Exec HEAD request with redirect following
    let response: wreq::Response = client.head(&url)
        .headers(header_map.clone())
        .redirect(Policy::limited(10))
        .send()
        .await?;

    // Fallback
    let final_response: wreq::Response = if response.status().is_success() {
        response
    } else {
        let get_response = client.get(&url)
            .headers(header_map)
            .redirect(Policy::limited(10))
            .send()
            .await?;
        if !get_response.status().is_success() {
            anyhow::bail!("Fallback GET failed: {}", get_response.status());
        }
        get_response
    };

    // Headers extract
    let mut result_headers: HashMap<String, String> = HashMap::new();
    for (key, value) in final_response.headers() {
        let val_str = value.to_str().unwrap_or("").to_string();
        result_headers.insert(key.as_str().to_lowercase(), val_str);
    }
    Ok(result_headers)
}

// Chunck downloading
pub async fn download_chunk_rust(
    stream_sink: StreamSink<Vec<u8>>,
    url: String,
    _start: u64, // u64 for big files
    _end: u64,
    headers: HashMap<String, String>
) -> anyhow::Result<()> {
    if _start > _end {
        anyhow::bail!("Range invalido: start > end");
    }

    let client = Client::builder()
        .emulation(Emulation::Chrome130)
        .build()?;

    // Setup headers
    let mut header_map = header::HeaderMap::new();
    for (k, v) in headers {
        if k.eq_ignore_ascii_case("host") { continue; }

        if let Ok(k_name) = header::HeaderName::from_bytes(k.as_bytes()) {
            if let Ok(v_val) = header::HeaderValue::from_str(&v) {
                header_map.insert(k_name, v_val);
            } else {
                eprintln!("Header value invalido: {}", v);
            }
        } else {
            eprintln!("Header key invalido: {}", k);
        }
    }

    // GET request
    let response: wreq::Response = client.get(&url)
        .headers(header_map)
        .redirect(Policy::limited(10))
        .send()
        .await?;

    if !response.status().is_success() && response.status() != wreq::StatusCode::PARTIAL_CONTENT {
        anyhow::bail!("Server refused connection: {}", response.status());
    }

    let mut stream = response.bytes_stream();
    while let Some(item) = stream.next().await {
        match item {
            Ok(bytes) => {
                if let Err(e) = stream_sink.add(bytes.to_vec()) {
                    break;
                }
            }
            Err(e) => anyhow::bail!("Error reading stream: {}", e),
        }
    }
    Ok(())
}