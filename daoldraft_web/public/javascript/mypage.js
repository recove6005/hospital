var subscribeType = '';
var pjtIndex = 0;

async function getUserInitData() {
    // 구독권 타입
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        subscribeType = result.subscribe;
    } else {
        console.log(`error : ${result.error}`);
    }
}

// 구독 정보 적용
async function getSubscribeInfos() {
    await getUserInitData();

    if(subscribeType === '0') {
        // 구독권 없음

    } else {
        const response = await fetch('/user/get-subscribe-info', {
            method: 'POST',
        });
    
        const result = await response.json();
        if(response.ok) {
            
        } else {
            console.log(`error: ${result.error}`);
        }
    }
}
getSubscribeInfos();

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

// 비밀번호 변경
document.getElementById('update-password').addEventListener('click', async (e) =>  {
    Swal.fire({
        title: '비밀번호 재설정',
        text: '비밀번호를 변경하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소',
    }).then(async (result) => {
        if(result.isConfirmed) {
            try {
                const updateResponse = await fetch('/login/update-password', {
                    method: 'POST',
                    credentials: "include",
                });
                
                if(updateResponse.ok) {
                    Swal.fire('성공', '비밀번호 변경 링크가 전송되었습니다. 이메일을 확인해 주세요.', 'success');
                } else {
                    const errorData = await response.json();
                    console.log(`Error: ${errorData.error}`);
                    Swal.fire('오류', '비밀번호 변경 요청 중 문제가 발생했습니다.', 'error');
                }
            } catch (error) {
                console.error('Request failed:', error);
                Swal.fire('오류', '서버와 통신 중 문제가 발생했습니다.', 'error');
            }
        }
    }); 
});


// Project 데이터 리스트 (예시 데이터)
const userProjects = [];
let pagedProjects = [];

// 프로젝트 정보 가져오기
async function getProjects() {
    const response = await fetch('/project/get-projects-by-uid', {
        method: 'POST',
    });

    const result = await response.json();
    if(response.ok) {
        result.forEach((pjt) => {
            userProjects.push(pjt);
        });
    } else {
        console.log(`error: ${result.error}`);
    }
}
await getProjects();


async function getPrice(docId) {
    const response = await fetch('/project/get-price', {
        method: 'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            docId: docId,
        }),
    });

    const result = await response.json();
    if(response.ok) {
        return result.price;
    } else {
        return '---';
    }
}

// 프로젝트 리스트 페이저 구현
let page = 0;
async function setIndexes() {
    const indexWrapper = document.getElementById('project-indexes');
    if(!indexWrapper) console.log(`error: .indexes is not exists.`);

    for(let i = 0; i < 5; i++) {
        const itemA = document.createElement('a');
        itemA.innerText = `${page+i+1}`;
        itemA.addEventListener('click', (e) => {
            e.preventDefault();
            
            indexWrapper.innerHTML = '';
            pagedProjects = [];
            
            const indexStart = (parseInt(itemA.innerText, 10)-1)*5;
            let currentIndex = 0;
            for(let i = 0; i < 5; i++) {
                currentIndex = indexStart + i;
                if(userProjects[currentIndex]) pagedProjects.push(userProjects[currentIndex]);
            }

            initProjectInfo();
        });

        indexWrapper.appendChild(itemA);
    }    
}


    
// 페이저 버튼
document.getElementById('pager-prev-btn').addEventListener('click', (e) => {
    e.preventDefault();
    if(page != 0) page -= 5;
    console.log(page);
    initProjectInfo();
});

document.getElementById('pager-next-btn').addEventListener('click', (e) => {
    e.preventDefault();
    console.log(page);

    initProjectInfo();
});


// 초기 UI 업데이트 함수
async function initProjectInfo() {
    await setIndexes();
    const projectList = document.querySelector('.project-list ul');

    // 프로젝트 표시
    if(pagedProjects.length === 0) {
       
    } else {
        pagedProjects.forEach( async (pjt) => {    
            // 문의 일자
            const date = new Date(pjt.date);
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const formattedDate = `${year}-${month}-${day}`;
    
            // 가격
            const price = await getPrice(pjt.docId);

            // 프로젝트ID
            const docId = pjt.docId;

            // 프로젝트 진행 현황
            let progress = '문의 접수';
            if(pjt.progress == '1') progress = '작업 중';
            if(pjt.progress == '2' || pjt.progress == '11') progress = '결제 중';
            if(pjt.progress == '3') progress = '결제 완료';

            const itemLi = document.createElement('li');
            const itemA = document.createElement('a');
            itemA.classList.add('project-list-item');
            itemA.innerHTML = `
                <p class="item-detail">${pjt.title}</p>
                <p class="item-detail">${progress}</p>
                <p class="item-detail">${formattedDate}</p>
                <p class="item-detail">${price}</p>
            `;

            itemA.addEventListener("click", () => {
                window.location.href = `../html/project-info.html?docId=${docId}`;    
            });
            
            itemLi.appendChild(itemA);
            projectList.appendChild(itemLi);

        });
    }    
}

await initProjectInfo();