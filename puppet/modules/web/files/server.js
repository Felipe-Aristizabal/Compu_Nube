const os = require('os');
const Consul = require('consul');
const express = require('express');

const app = express();
const PORT = Number(process.argv[2] || 3000);

const ifs = os.networkInterfaces();
const HOST = ifs['eth1'].find(i => i.family === 'IPv4').address;
const SERVICE_NAME = 'web';
const SERVICE_ID = `${SERVICE_NAME}-${HOST}-${PORT}`;


const consul = new Consul({ host: '127.0.0.1', port: 8500 });

app.get('/health', (_req, res) => res.end('OK'));
app.get('/', (_req, res) => res.json({ pid: process.pid, host: HOST, port: PORT }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`web escuchando en http://${HOST}:${PORT}`);
  const def = {
    id: SERVICE_ID,
    name: SERVICE_NAME,
    address: HOST,
    port: PORT,
    check: {
      http: `http://${HOST}:${PORT}/health`,
      interval: '5s',
      timeout: '2s',
      deregister_critical_service_after: '1m'
    }
  };
  consul.agent.service.register(def, (err) => {
    if (err) console.error('registro consul falló (la app sigue):', err.message);
    else console.log('registrado en consul:', SERVICE_ID);
  });
});

const bye = () => consul.agent.service.deregister(SERVICE_ID, () => process.exit(0));
process.on('SIGINT', bye);
process.on('SIGTERM', bye);
                            