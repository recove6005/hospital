document.getElementById("login-button").addEventListener("click", async (e) => {
    e.preventDefault();

    const loadingScreen = document.getElementById("loading-screen");
    loadingScreen.style.display = "flex"; // 로딩 화면 표시
    
    const param = new URLSearchParams(window.location.search);
    const email = param.get('email');
    document.getElementById('email').value = email;

    const password = document.getElementById('password').value;
    
    try {
        const loginResponse = await fetch('/login/login', {
            method: 'POST',
            headers: {'Content-Type':'application/json'},
            body: JSON.stringify({email, password}),
        });

        const loginResult = await loginResponse.json();
        if(loginResponse.ok) {
            alert(`어서오세요, ${loginResult.email}`);

            window.location.href = "/html/home.html";
        } 
        else if(loginResult.code === 'auth/invalid-credential') {
            // 사용자가 없음 >> 회원가입 절차
            const response = await fetch('/login/register', {
                method: 'POST',
                headers: { 'Content-Type' : 'application/json'},
                body: JSON.stringify({ email, password }),
            });

            if(response.ok) {
                alert(`어서오세요, ${email}님`);
                window.location.href = "/html/home.html";
            }
        }
        else if(loginResult.code === 'auth/wrong-password') {
            alert('비밀번호가 옳지 않습니다.');
        }
        else if(loginResult.code === 'auth/too-many-requests') {
            alert('잠시 후에 다시 시도해주세요.');
        } else {
            alert(`error: ${loginResult.code}`);
        }
    } catch(e) {
        console.error("Error:", e);
        alert("An error occurred: " + e.message);
    } finally {
        loadingScreen.style.display = "none"; // 로딩 화면 숨김
    };
});