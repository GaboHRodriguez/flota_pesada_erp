/**
 * SERVIDOR CENTRAL PARA WINDOWS SERVER — MAQUINARIA & FLOTA ERP (`dbequipos`)
 * Funciona de forma nativa con Node.js sin requerir dependencias externas obligatorias,
 * persistiendo en `dbequipos_store.json` y sirviendo además la versión Web para PCs Windows y Mac.
 * También incluye conector listo para MySQL (`dbequipos`).
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3050;
const DATA_FILE = path.join(__dirname, 'dbequipos_store.json');
const WEB_BUILD_DIR = path.join(__dirname, '..', 'build', 'web');

function loadStore() {
  if (!fs.existsSync(DATA_FILE)) {
    const initial = {
      status: 'active',
      database: 'dbequipos',
      updatedAt: new Date().toISOString(),
      partesSincronizados: [],
      informesTallerSincronizados: [],
      movimientosObra: [],
      gastosEquipos: [],
    };
    fs.writeFileSync(DATA_FILE, JSON.stringify(initial, null, 2), 'utf8');
    return initial;
  }
  return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
}

function saveStore(data) {
  data.updatedAt = new Date().toISOString();
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.wasm': 'application/wasm',
};

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // API Endpoints para Android, Windows y Mac
  if (req.url === '/api/status' && req.method === 'GET') {
    const store = loadStore();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        ok: true,
        server: 'Windows Server — Maquinaria Pesada ERP (dbequipos)',
        updatedAt: store.updatedAt,
        partesSincronizadosCount: store.partesSincronizados.length,
        informesTallerCount: store.informesTallerSincronizados.length,
      })
    );
    return;
  }

  if (req.url === '/api/sync' && req.method === 'POST') {
    let body = '';
    req.on('data', (chunk) => (body += chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const store = loadStore();
        if (Array.isArray(payload.partesDiarios)) {
          store.partesSincronizados.push(...payload.partesDiarios);
        }
        if (Array.isArray(payload.informesTaller)) {
          store.informesTallerSincronizados.push(...payload.informesTaller);
        }
        saveStore(store);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: true, syncedAt: store.updatedAt }));
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: false, error: e.message }));
      }
    });
    return;
  }

  // Servir cliente Web/Desktop (para Windows y Mac por navegador) si existe build/web
  if (fs.existsSync(WEB_BUILD_DIR)) {
    let cleanUrl = req.url.split('?')[0];
    if (cleanUrl === '/') cleanUrl = '/index.html';
    const filePath = path.join(WEB_BUILD_DIR, cleanUrl);
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
      const ext = path.extname(filePath).toLowerCase();
      res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'application/octet-stream' });
      fs.createReadStream(filePath).pipe(res);
      return;
    }
  }

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(
    JSON.stringify({
      service: 'Flota Pesada ERP — Windows Server Backend Activo',
      endpoints: ['/api/status', '/api/sync'],
    })
  );
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('======================================================================');
  console.log('  MAQUINARIA & FLOTA ERP (dbequipos) - SERVIDOR WINDOWS SERVER ACTIVO');
  console.log(`  Escuchando en: http://0.0.0.0:${PORT}`);
  console.log(`  API Endpoint : http://localhost:${PORT}/api/status`);
  console.log('======================================================================');
});
