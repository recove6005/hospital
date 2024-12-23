

document.getElementById("complete").addEventListener("submit", async (e) => {
    e.preventDefault();

    const email = localStorage.getItem("email");
    const password = document.getElementById("password").value;
    console.log(`${email}, ${password}`);

    try {
        const response = await fetch('/signinsignup', {
            method: 'POST',
            headers: {'Content-Type':'application/json'},
            body: JSON.stringify({email, password}),
        });

        const result = await response.json();
        if(response.ok) {
            console.log("Login successful:", result.email);
            alert(`Welcome, ${result.email}`);
        }
    } catch(e) {
        console.error("Error:", e);
        alert("An error occurred: " + e.message);
    };
});