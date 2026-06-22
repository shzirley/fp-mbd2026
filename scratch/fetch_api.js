const http = require('http');

http.get('http://localhost:5000/api/schedules/JD0001/seats', (resp) => {
  let data = '';

  resp.on('data', (chunk) => {
    data += chunk;
  });

  resp.on('end', () => {
    try {
        const json = JSON.parse(data);
        console.log("Full JSON keys:", Object.keys(json));
        console.log(json);
    } catch(e) {
        console.error(e, data);
    }
  });

}).on("error", (err) => {
  console.log("Error: " + err.message);
});
