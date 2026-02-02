const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1>🎉 Jenkins CI/CD Success!</h1>
        <p>This app was automatically deployed by Jenkins!</p>
        <p>Build: ${process.env.BUILD_NUMBER || 'local'}</p>
      </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
});
