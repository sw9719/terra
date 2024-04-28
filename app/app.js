const express = require('express')
const PORT = 3000
const HOST = '0.0.0.0'

// App
const app = express()
app.get('/', (req, res) => {
  res.status(200)
  const data = {"message": "This is It. Nice Work"}
  res.setHeader('Content-Type', 'application/json')
  res.setHeader('Access-Control-Allow-Headers','*')
  res.setHeader('Access-Control-Allow-Origin','*')
  res.setHeader('Access-Control-Allow-Methods','OPTIONS,POST,GET')
  res.send(JSON.stringify(data))
});

app.listen(PORT, HOST)
console.log(`Our app running on http://${HOST}:${PORT}`)
