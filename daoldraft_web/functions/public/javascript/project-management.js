async function checkUserVerify() {
    const response = await fetch('/login/verify', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        if(result.msg.includes("verify0")) {
            window.location.reload();
            alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
        } 
        else {
            document.getElementById("profile-photo").style.visibility = 'visible';
            document.getElementById("profile-photo").style.display = 'flex';
            document.getElementById("profile-photo").style.flexDirection = 'raw';
            document.getElementById("profile-photo").style.alignItems = 'center';            
            document.getElementById("to-signin").style.display = 'none';
        }
    }
}
checkUserVerify();

// 드롭다운 관리자 계정 전용 링크 설정
async function checkUserAdminAndDisplay() {
    const response = await fetch('/login/check-admin', {
        method: 'POST',
        credentials: "include",  
    });

    const result = await response.json();

    if(response.ok) {
        if(result.admin) document.getElementById('dropdown-management').style.display = 'block';  
        else document.getElementById('dropdown-management').style.display = 'none';  
    } else {
        console.log(`error: ${result.error}`);
    }
}
checkUserAdminAndDisplay();

// Profile link 클릭 시 드롭다운 토글
document.getElementById('profile-link').addEventListener('click', function (e) {
    e.preventDefault(); // 기본 앵커 동작 방지
    const dropdownMenu = document.getElementById('dropdown-menu');
    
    // 드롭다운 메뉴 보이기/숨기기
    if (dropdownMenu.style.display === 'none' || dropdownMenu.style.display === '') {
        dropdownMenu.style.display = 'block';
    } else {
        dropdownMenu.style.display = 'none';
    }
});

// 다른 영역 클릭 시 드롭다운 닫기
document.addEventListener('click', function (e) {
    const dropdownMenu = document.getElementById('dropdown-menu');
    const profilePhoto = document.getElementById('profile-photo');

    if (!profilePhoto.contains(e.target)) {
        dropdownMenu.style.display = 'none';
    }
});

document.getElementById("to-signin").addEventListener('click', () => {
    window.location.href = "/html/login-email.html";
});

// 드롭다운 메뉴 로그아웃
document.getElementById("dropdown-logout").addEventListener('click', async (e) => {
    try {
        const response = await fetch('/login/logout', {
            method: 'POST',
            credentials: 'include',
        });

        if(!response.ok) {
            const error = await response.json();
            console.error("Logout failed:", error.msg || "Unknown error");
            alert(`Error: ${error.msg || "Logout failed."}`);
            return;
        }

        const result = await response.json();
        console.log(result.msg);

        // 드롭다운 메뉴 숨기기
        const dropdownMenu = document.getElementById('dropdown-menu');
        dropdownMenu.style.display = 'none';

        // 프로필 구역 UI변경
        document.getElementById("profile-photo").style.visibility = 'hidden';
        document.getElementById("profile-photo").style.display = 'none';

        document.getElementById("to-signin").style.visibility = 'visible';
        document.getElementById("to-signin").style.display = 'block';

        window.location.href="../html/home.html";
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});


// 전체 프로젝트 보기
async function getProjects(progress) {
    var response;
    
    // 리스트 가져오기
    if(progress === '0') {
        response = await fetch('/project/get-project-0', {
            method: 'POST',
        });
    }
    else if(progress === '1') {
        response = await fetch('/project/get-project-1', {
            method: 'POST',
        });
    }
    else if(progress === '2' ) {
        response = await fetch('/project/get-project-2', {
            method: 'POST',
        });
    } else if(progress === '3') {
        response = await fetch('/project/get-project-3', {
            method: 'POST',
        });
    } else if(progress === 'all') {
        response = await fetch('/project/get-project-all', {
            method: 'POST',
        });
    }
    const allPjtResult = await response.json();
    
    if(!response.ok) {
        console.log(allPjtResult.error);
    }

    if(allPjtResult.length === 0) {
        return;
    }

    allPjtResult.forEach(async (pjt) => {
        const listElement = document.getElementById('project-list');
        const item = document.createElement('li');

        const date = new Date(pjt.date);
        const formattedDate = `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
        
        var progress = '문의 접수';
        if(pjt.progress === '1') progress = '작업 중';
        else if(pjt.progress === '2' || pjt.progress === '11') progress = '결제 중';
        else if(pjt.progress === '3') progress = '결제 완료';

        var email = pjt.email;
        if(email === "") email = pjt.userEmail;

        item.innerHTML = `
            <a class="project-item" href="#">
                    <input type="hidden" id="project-id" value="${pjt.docId}">
                    <div id="item-top">
                        <div> 
                            <div id="title-notifier"> </div>
                            <p id="project-title">${pjt.title}</p>
                            <p id="project-progress">${progress}</p>
                        </div>
                        <div id="date">${formattedDate}</div>
                    </div>
                    <div id="item-bottom">
                        <p id="project-organization">${pjt.organization}</p>
                        <p id="proejct-phone">☎ ${pjt.call}</p>  
                    </div>
            </a>
            <div id="divider"></div>
        `;

        const projectLink = item.querySelector('.project-item');
        projectLink.addEventListener('click', (event) => {
            event.preventDefault();

            // 프로젝트 상세 페이지로 이동
            const projectId = projectLink.querySelector('#project-id').value;
            window.location.href = `../html/project-management-details.html?projectid=${projectId}`;
        });

    
        // else {
        //     // 결제 완료
        //     acceptBtn.style.display = 'none';
        //     dismissBtn.style.display = 'none';
        //     priceInput.style.display = 'none';
        //     paymentBtn.style.display = 'none';
        //     fileInput.style.display = 'none';
        //     checkPaymentBtn.style.display = 'none';
        //     depositOwnner.style.display = 'inline-block';

        //     // 예금주 이름
        //     const response = await fetch('/project/download-deposit-owner', {
        //         method: 'POST',
        //         headers: { "Content-Type" : "application/json" },
        //         body: JSON.stringify({
        //             docId: pjt.docId,
        //         }),
        //     });

        //     const result = await response.json();
        //     let owner = '';
        //     if(response.ok) {
        //         owner = result.owner;
        //     } else {
        //         console.log(`error: ${result.error}`);
        //     }

        //     depositOwnner.innerText = `(무통장 입금) 예금주: ${owner}`;
        // }

        // 결제확인 버튼 이벤트
        // checkPaymentBtn.addEventListener('click', async (e) => {
        //     Swal.fire({
        //         title: '결제 확인 처리',
        //         text: '무통장 입금 결제를 확인 처리하시겠습니까? 요청자가 파일을 다운로드 할 수 있습니다.',
        //         showCancelButton: true,
        //         confirmButtonText: '확인',
        //         cancelButtonText: '취소',
        //     }).then( async (result) => {
        //         if(result.isConfirmed) {
        //             const response = await fetch('/project/check-deposit', {
        //                 method: 'POST',
        //                 headers: { "Content-Type" : "application/json "},
        //                 body: JSON.stringify({ docId: pjt.docId }),
        //             });
        
        //             const result = await response.json();
        //             if(response.ok) {
        //                 window.location.reload();
        //             } else {
        //                 console.log(`error: ${result.error}`);
        //             }

        //             Swal.fire('', '무통장 입금이 확인되었습니다.', 'success');
        //         }
        //     });
        // });
        
        listElement.appendChild(item);
    }); 
}
getProjects('all');


// 프로젝트 분류 버튼 로직
document.getElementById('project-all').addEventListener('click', (e) => { 
    document.getElementById('project-list').innerHTML = ''; 
    getProjects('all');
});

document.getElementById('project-0').addEventListener('click', (e) => { 
    document.getElementById('project-list').innerHTML = ''; 
    getProjects('0');
});

document.getElementById('project-1').addEventListener('click', (e) => { 
    document.getElementById('project-list').innerHTML = ''; 
    getProjects('1');
});

document.getElementById('project-2').addEventListener('click', (e) => { 
    document.getElementById('project-list').innerHTML = ''; 
    getProjects('2');
});

document.getElementById('project-3').addEventListener('click', (e) => { 
    document.getElementById('project-list').innerHTML = ''; 
    getProjects('3');
});

