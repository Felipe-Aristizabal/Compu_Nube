let counts = {};

function countHosts(req, res, context, ee, next) {
  try {
    const host = context.vars.host;
    counts[host] = (counts[host] || 0) + 1;
  } catch (e) {
    console.error("Error parsing host:", e.message);
  }
  return next();
}

function summarize() {
  console.log("=== Distribución de respuestas por host ===");
  for (const [host, n] of Object.entries(counts)) {
    console.log(`${host}: ${n} respuestas`);
  }
}

module.exports = { countHosts, summarize };