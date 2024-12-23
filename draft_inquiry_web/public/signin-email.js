document.getElementById('signin').addEventListener("submit", (e) =>{
    e.preventDefault();
    const email = document.getElementById("email").value;
    
    localStorage.setItem("email", email);
    window.location.href = "signin-password.html";
});