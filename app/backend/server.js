const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
 
app.get('/', (req, res) => {
  res.json({
    message: "Backend API is running",
    version: "1.0.0",
    timestamp: new Date()
  });
});
 
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});
 
app.get('/metadata', (req, res) => {
  res.json({
    build_number: process.env.BUILD_NUMBER || "local",
    commit: process.env.GIT_COMMIT || "unknown"
  });
});
 
app.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
});
 
