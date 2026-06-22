async function run() {
  try {
    const res = await fetch('http://localhost:5000/api/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        userId: 'PL0024',
        scheduleId: 'JD0017', // Dilan 1990
        seats: ['A1'], // Random seat
        canteenItems: [],
        paymentMethod: 'Qris',
        totalBill: 50000
      })
    });
    const data = await res.json();
    console.log(data);
  } catch(e) {
    console.error(e);
  }
}
run();
