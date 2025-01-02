document.getElementById("payment-form").addEventListener("submit", async (e) => {
    e.preventDefault();

    const response = await fetch("/user/periodic-purchase", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            name: document.getElementById("cardholder-name").value,
            cardNumber: document.getElementById("card-number").value,
            expiryDate: document.getElementById("expiry-date").value,
            cvv: document.getElementById("cvv").value,
        }),
    });

    const result = await response.json();
    if (response.ok) {
        alert(`Subscription created successfully: ${result.subscriptionId}`);
    } else {
        alert(`Error: ${result.error}`);
    }
});