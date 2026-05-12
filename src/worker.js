const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const OWNER  = 'SinisterNL';
const REPO   = 'SinisterNL.github.io';
const BRANCH = 'main';

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS });
    }

    if (url.pathname.startsWith('/api/') && request.method === 'POST') {
      switch (url.pathname) {
        case '/api/analyze-photo': return analyzePhoto(request, env);
        case '/api/upload-image':  return uploadImage(request, env);
        case '/api/update-index':  return updateIndex(request, env);
      }
    }

    return env.ASSETS.fetch(request);
  }
};

// ── Anthropic: analyze photo → section + caption ──────────────────────────
async function analyzePhoto(request, env) {
  try {
    const { imageData, mediaType } = await request.json();

    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 200,
        system: `You categorize photos for a personal website with two sections:
- "curacao": life on Curaçao island (beaches, coast, food, drinks, scenery, daily life)
- "miniatures": Warhammer hobby (painted figurines, paint sets, brushes, hobby materials)
Respond ONLY with valid JSON, no markdown: {"section":"curacao","caption":"Short caption six words max"}`,
        messages: [{
          role: 'user',
          content: [
            { type: 'image', source: { type: 'base64', media_type: mediaType, data: imageData } },
            { type: 'text', text: 'Categorize this photo and write a caption.' }
          ]
        }]
      })
    });

    const data = await res.json();
    const text = data.content?.[0]?.text?.trim() ?? '';
    const result = JSON.parse(text.replace(/```json|```/g, '').trim());
    return json(result);
  } catch (err) {
    return json({ error: err.message }, 500);
  }
}

// ── GitHub: upload image file ──────────────────────────────────────────────
async function uploadImage(request, env) {
  try {
    const { filename, imageData } = await request.json();

    let sha;
    try {
      const check = await github(`contents/images/${filename}`, 'GET', null, env);
      sha = check.sha;
    } catch {}

    await github(`contents/images/${filename}`, 'PUT', {
      message: `Add image: ${filename}`,
      content: imageData,
      branch: BRANCH,
      ...(sha ? { sha } : {})
    }, env);

    return json({ ok: true });
  } catch (err) {
    return json({ error: err.message }, 500);
  }
}

// ── GitHub: inject photo into index.html array ────────────────────────────
async function updateIndex(request, env) {
  try {
    const { section, filename, caption } = await request.json();

    const indexData = await github('contents/index.html', 'GET', null, env);
    let html = atob(indexData.content.replace(/\n/g, ''));
    const sha = indexData.sha;

    const marker = section === 'miniatures' ? 'END_MINIATURES' : 'END_CURACAO';
    if (!html.includes(`// ${marker}`)) {
      throw new Error(`Marker ${marker} not found in index.html`);
    }

    const newEntry = `      { src: "images/${filename}", caption: "${caption}" },\n    `;
    html = html.replace(`    ]; // ${marker}`, `    ${newEntry}]; // ${marker}`);

    await github('contents/index.html', 'PUT', {
      message: `Add ${filename} to ${section}`,
      content: btoa(unescape(encodeURIComponent(html))),
      sha,
      branch: BRANCH
    }, env);

    return json({ ok: true });
  } catch (err) {
    return json({ error: err.message }, 500);
  }
}

// ── GitHub API helper ──────────────────────────────────────────────────────
async function github(path, method, body, env) {
  const res = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/${path}`, {
    method,
    headers: {
      'Authorization': `Bearer ${env.GH_TOKEN}`,
      'Content-Type': 'application/json',
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'SinisterNL-Worker'
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || res.statusText);
  return data;
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' }
  });
}
