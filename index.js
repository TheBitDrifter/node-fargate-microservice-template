const express = require('express');

// The port must match the 'container_port' (3000) defined in your Terraform modules
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';

const app = express();

// --- Root Path: / and /:serviceName ---
// Handles direct access and access via ALB path routing (e.g. /nodeTemplateTester)
// Express treats /foo and /foo/ differently by default, so we match both or use a regex.
app.get(['/', '/:serviceName', '/:serviceName/'], (req, res) => {
  const serviceName = req.params.serviceName || 'root';
  console.log(JSON.stringify({
    level: 'info',
    message: 'Request received',
    path: req.path,
    serviceName: serviceName,
    userAgent: req.get('User-Agent')
  }));
  // Returns a simple confirmation message
  res.send(`Hello from the Node.js Microservice! Running in Fargate on port ${PORT}`);
});

// --- Health Check Path: /health and /:serviceName/health ---
// This endpoint is used by the ALB to check if the container is alive and ready.
app.get(['/health', '/:serviceName/health'], (req, res) => {
  console.log(JSON.stringify({
    level: 'info',
    message: 'Health check passed',
    status: 'healthy'
  }));
  res.status(200).json({ status: 'healthy' });
});

// Start the server
app.listen(PORT, HOST, () => {
  console.log(JSON.stringify({
    level: 'info',
    message: `Server running on http://${HOST}:${PORT}`
  }));
});
