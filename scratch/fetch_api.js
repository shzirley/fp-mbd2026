async function run() {
  try {
    const res = await fetch('http://localhost:5000/api/user/PL0024/tickets');
    const data = await res.json();
    console.log("PL0024 Tickets:", data);
  } catch(e) {
    console.error(e);
  }
}
run();
