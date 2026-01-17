import React from "react";
 
function App() {
  return (
    <div style={{ padding: "40px", fontFamily: "Arial" }}>
      <h1>🚀 DevOps Master Platform</h1>
 
      <p>This application is deployed using:</p>
 
      <ul>
        <li>Terraform</li>
        <li>Jenkins CI/CD</li>
        <li>Docker</li>
        <li>AWS ECR</li>
        <li>Kubernetes (EKS)</li>
      </ul>
 
      <h3>Status</h3>
      <p>Frontend is running successfully ✅</p>
 
      <h3>Backend</h3>
      <p>API Endpoint: <code>/api</code></p>
    </div>
  );
}
