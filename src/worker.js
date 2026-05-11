const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS });
    }

    if (url.pathname === '/api/analyze-photo' && request.method === 'POST') {
      return analyzePhoto(request, env);
    }

    return env.ASSETS.fetch(request);
  }
};

async function analyzePhoto(request, env) {
  try {
    const { imageData, mediaType } = await request.json();

    if (!env.ANTHROPIC_API_KEY) {
      return json({ error: 'ANTHROPIC_API_KEY not configured' }, 500);
    }

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
- "curacao": life on Curaçao island (beaches, coast, food, drinks, scenery, daily life outdoors)
- "miniatures": Warhammer hobby (painted miniature figurines, paint sets, brushes, hobby materials)

Respond ONLY with valid JSON, no markdown fences:
{"section":"curacao","caption":"Short caption six words max"}`,
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

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' }
  });
}
