document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if(emailRegex.test(email)) {
        window.location.href = `../html/login-password.html?email=${email}`;
    } else {
        alert('정확한 이메일을 입력해 주세요.');
    }
});