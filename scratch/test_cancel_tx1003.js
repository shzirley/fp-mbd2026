async function run() {
  try {
    const res = await fetch('http://localhost:5000/api/transactions/TX1003/cancel', { method: 'POST' });
    const data = await res.json();
    console.log("Cancel API Response:", data);
  } catch(e) {
    console.error(e);
  }
}
run();
