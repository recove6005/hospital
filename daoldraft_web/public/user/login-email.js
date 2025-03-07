document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if(emailRegex.test(email)) {
        window.location.href = `../user/login-password.html?email=${email}`;
    } else {
        alert('정확한 이메일을 입력해 주세요.');
    }
});

// 비밀번호 변경
document.getElementById('find-password-btn').addEventListener('click', async (e) =>  {
    e.preventDefault();
    const email = document.getElementById('email').value;

    if(email === '' || email.includes('@') === false) {
        alert('정확한 이메일을 입력해 주세요.');
        return;
    }

    Swal.fire({
        title: '비밀번호 재설정',
        text: '비밀번호를 재설정하시겠습니까? 해당 이메일로 비밀번호 재설정 링크가 전송됩니다.',
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소',
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        },
    }).then(async (result) => {
        if(result.isConfirmed) {
            try {
                const findResponse = await fetch('/login/find-password', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ email }),
                });
                
                if(findResponse.ok) {
                    Swal.fire('성공', '비밀번호 재설정 링크가 전송되었습니다. 이메일을 확인해 주세요.', 'success');
                } else {
                    const errorData = await findResponse.json();
                    console.log(`Error: ${errorData.error}`);
                    Swal.fire('오류', '요청 중 문제가 발생했습니다.', 'error');
                }
            } catch (error) {
                console.error('Request failed:', error);
                Swal.fire('오류', '서버와 통신 중 문제가 발생했습니다.', 'error');
            }
        }
    }); 
});
