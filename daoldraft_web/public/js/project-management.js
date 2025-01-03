
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

            document.getElementById("user-email").innerText = result.msg;
            
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
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});


// 전체 프로젝트 보기
async function getProjects(progress) {
    var response;

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
    
    allPjtResult.forEach((pjt) => {
        const listElement = document.getElementById('project-list');
        const item = document.createElement('li');

        const date = new Date(pjt.date);
        const formattedDate = `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
        
        var progress = '문의 접수';
        if(pjt.progress === '1') progress = '작업 중';
        else if(pjt.progress === '2') progress = '작업 완료, 결제 진행 중';
        else if(pjt.progress === '3') progress = '결제 완료';

        var email = pjt.email;
        if(email === "") email = pjt.userEmail;

        item.innerHTML = `
            <a class="project-item" href="#">
                    <input type="hidden" id="project-id" value="${pjt.docId}">
                    <div id="item-top">
                        <p id="proejct-title">${pjt.title}<span id="size">(${pjt.size})</span></p>
                        <p id="proejct-date">${formattedDate}</p>
                    </div>
                    <div id="item-middle">
                        <p id="project-organization">${pjt.organization}</p>
                        <p id="proejct-phone">${pjt.phone}</p>
                    </div>
                    <div id="item-progress">
                        <p id="project-progress">${progress}</p>
                    </div>
                    <div class="item-details hidden" id="item-details-${pjt.docId}">
                        <div id="item-agent">
                            <p class="details" id="name">담당자 : ${pjt.name}</p>
                            <p class="details" id="rank">직책 : ${pjt.rank}</p>
                            <p class="details" id="email">이메일 : ${email} </p>
                        </div>
                        <div id="item-content">
                            <p id="detail-title">문의내용 : </p>
                            <p class="details" id="details">${pjt.details}</p>
                        </div>
                        <div id="item-price">
                            <p class="details" id="price"> 가격 ${pjt.allprice}원</p>
                        </div>
                    </div>
                </a>     
                <div id="item-buttons">
                    <a class="item-button" id="accept-btn-${pjt.docId}">수락</a>
                    <a class="item-button" id="dismiss-btn-${pjt.docId}">거부</a>
                    <form id="payment-form-${pjt.docId}">
                        <input class="item-input" id="input-price-${pjt.docId}" name="price" placeholder="결제 요청 가격" required> 
                        <button class="item-button" id="payment-btn-${pjt.docId}">결제요청</button>
                    </form>
                </div>
        `;

        const projectLink = item.querySelector('.project-item');
        projectLink.addEventListener('click', (event) => {
            event.preventDefault(); // 기본 동작(페이지 이동) 방지
            const projectId = projectLink.querySelector('#project-id').value;
            console.log(`Project clicked: ${projectId}`);

            const detailBox = document.querySelector(`#item-details-${projectId}`);
            if (detailBox.classList.contains('hidden')) {
                detailBox.classList.remove('hidden'); // 보이기
                detailBox.style.display = 'block';
                
            } else {
                detailBox.classList.add('hidden'); // 숨기기
                detailBox.style.display = 'none';
            }
        });

        // 버튼 처리
        const acceptBtn = item.querySelector(`#accept-btn-${pjt.docId}`);
        const dismissBtn = item.querySelector(`#dismiss-btn-${pjt.docId}`);
        const priceInput = item.querySelector(`#input-price-${pjt.docId}`);
        const paymentBtn = item.querySelector(`#payment-btn-${pjt.docId}`);

        // 결제 input 문자열 제한
        priceInput.addEventListener("input", (e) => {
            const rawValue = e.target.value.replace(/[^\d]/g, "");
            const formattedValue = new Intl.NumberFormat("ko-KR").format(rawValue);
            e.target.value = formattedValue ? `${formattedValue}` : "";
        })

        if(pjt.progress === '0') {
            // 문의 접수
            acceptBtn.style.display = 'flex';
            dismissBtn.style.display = 'flex';
            priceInput.style.display = 'none';
            paymentBtn.style.display = 'none';
        }   
        else if(pjt.progress === '1') {
            // 작업 중
            acceptBtn.style.display = 'none';
            dismissBtn.style.display = 'none';
            priceInput.style.display = 'flex';
            paymentBtn.style.display = 'flex';
        }
        else {
            // 작업완료, 결제 요청
            // 결제 완료
            acceptBtn.style.display = 'none';
            dismissBtn.style.display = 'none';
            priceInput.style.display = 'none';
            paymentBtn.style.display = 'none';
        }

        // 작업 수락 버튼 이벤트
        acceptBtn.addEventListener('click', async (e) => {
            // project progress update 0 -> 1
            const response = await fetch('/project/accept-project', {
                method: 'POST',
                headers: { "Content-Type" : "application/json"},
                body: JSON.stringify({ docId: pjt.docId }),
            });

            const acceptResult = await response.json();
            if(response.ok) {
                window.location.reload();
            } else {
                console.log(`${acceptResult.error}`);
            }
        });

        // 작업 거부 버튼 이벤트
        dismissBtn.addEventListener('click', async (e) => {
            // project delete
            const response = await fetch('/project/dismiss-project', {
                method: 'POST',
                headers: { "Content-Type" : "application/json "},
                body: JSON.stringify({ docId: pjt.docId }),
            });

            const dismissResult = await response.json();
            if(response.ok) {
                window.location.reload();
            } else {
                console.log(`${dismissResult.error}`);
            }
        });

        // 결제요청 버튼 이벤트
        const paymentForm = item.querySelector(`#payment-form-${pjt.docId}`);
        paymentForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const price = priceInput.value;

            // project progress update 1 -> 2
            // 결제 요청 처리
            const response = await fetch('/project/request-payment', {
                method: 'POST',
                headers: { "Content-Type" : "application/json" },
                body: JSON.stringify({
                    docId: pjt.docId,
                    price: price,
                }),
            });

            const paymentResult = await response.json();
            if(response.ok) {
                alert(`${pjt.organization}에서 문의한 ${pjt.title} ${pjt.size}프로젝트의 ${price}원 결제 요청이 완료되었습니다.`);
                window.location.reload(); 
            } else {
                console.log(`${paymentResult.error}`);
            }
        });
        
        listElement.appendChild(item);
    }); 
}
getProjects('all');


// 프로젝트 분류 버튼 로직
document.getElementById('project-all').addEventListener('click', (e) => { getProjects('all')});
document.getElementById('project-1').addEventListener('click', (e) => { getProjects('0')});
document.getElementById('project-1').addEventListener('click', (e) => { getProjects('1')});
document.getElementById('project-2').addEventListener('click', (e) => { getProjects('2')});
document.getElementById('project-3').addEventListener('click', (e) => { getProjects('3')});