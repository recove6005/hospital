document.getElementById("login-button").addEventListener("click", async (e) => {
    e.preventDefault();

    const param = new URLSearchParams(window.location.search);
    const email = param.get('email');
    document.getElementById('email').value = email;

    const password = document.getElementById('password').value;
    
    try {
        const response = await fetch('/login/login', {
            method: 'POST',
            headers: {'Content-Type':'application/json'},
            body: JSON.stringify({email, password}),
        });

        const result = await response.json();
        if(response.ok) {
            console.log("Login successfully.");
            alert(`Welcome, ${email} (${result.uid})`);

            window.location.href = "/html/index.html";
        }
    } catch(e) {
        console.error("Error:", e);
        alert("An error occurred: " + e.message);
    };
});