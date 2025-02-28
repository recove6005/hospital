var orders = [];

document.getElementById('entry-btn').addEventListener('click', async () =>{
    const key = document.getElementById('entry-key').value;
    const keyCheckResponse = await fetch('/api/entry/validate', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ key: key }),
    });    

    if(keyCheckResponse.ok) {
        // 초기 진입 시 전체 데이터 표시
        const getOrdersResponse = await fetch('/api/product/get-all-orders');
        if(getOrdersResponse.ok) {
            const entryInputContainer = document.getElementById('entry-container');
            entryInputContainer.style.display = 'none';
        
            const entrySuccessContainer = document.getElementById('entry-success-container');
            entrySuccessContainer.style.display = 'block';
        
            const ulElement = document.getElementById('entry-success-list');
            orders = await getOrdersResponse.json();

            if(orders.length === 0) {
                ulElement.innerHTML = `<p id='search-result-empty'>요청된 주문이 없습니다.</p>`;
                return;
            }

            orders.forEach(order => {
                const orderDate = order.order_date.substring(0, 10);
                const liElement = document.createElement('li');
                liElement.innerHTML = `
                    <div class='list-tile' id="check-tile">
                        <input type='checkbox' id='order-checkbox' value='${order.order_id}'>
                    </div>
                    <p class='list-tile'>${orderDate}</p>
                    <p class='list-tile'>${order.product_name}</p>
                    <p class='list-tile'>${order.quantity}</p>
                    <p class='list-tile'>${order.standard}</p>
                    <p class='list-tile'>${order.hospital_name}</p>
                    <p class='list-tile'>${order.call_num}</p>
                    <p class='list-tile'>${order.email}</p>
                    <p class='order-details'>${order.details}</p>
                `;  
                ulElement.appendChild(liElement);
            });
        }
        
    }
});


function isDateBeforeToday(date) {
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    const inputDate = new Date(date);
    return inputDate <= today;
}

function isStartDateBeforeEndDate(startDate, endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);
    return start <= end;
}

// 주문 검색 - 기간별
document.getElementById('search-btn').addEventListener('click', async () => {
    const startDate = document.getElementById('search-start-date').value;
    const endDate = document.getElementById('search-end-date').value;

    console.log(startDate, endDate);

    if(startDate === '' || endDate === '') {
        alert('날짜를 선택해주세요.');
        return;
    }

    if(!isDateBeforeToday(startDate) || !isDateBeforeToday(endDate)) {
        alert('오늘 이전 날짜를 선택해주세요.');
        return;
    }

    if(!isStartDateBeforeEndDate(startDate, endDate)) {
        alert('시작 날짜가 종료 날짜보다 이전이어야 합니다.');
        return;
    }

    const searchResponse = await fetch('/api/product/get-scoped-orders', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            startDate: startDate,
            endDate: endDate
        }),
    });

    if(searchResponse.ok) {
        const ulElement = document.getElementById('entry-success-list');
        ulElement.innerHTML = '';

        orders = await searchResponse.json();

        orders.forEach(order => {
            const orderDate = order.order_date.substring(0, 10);
            const liElement = document.createElement('li');
            liElement.innerHTML = `
                <div class='list-tile' id="check-tile">
                <input type='checkbox' id='order-checkbox' value='${order.order_id}'>
                </div>
                <p class='list-tile'>${orderDate}</p>
                <p class='list-tile'>${order.product_name}</p>
                <p class='list-tile'>${order.quantity}</p>
                <p class='list-tile'>${order.standard}</p>
                <p class='list-tile'>${order.hospital_name}</p>
                <p class='list-tile'>${order.call_num}</p>
                <p class='list-tile'>${order.email}</p>
                <p class='order-details'>${order.details}</p>
            `;
            ulElement.appendChild(liElement);
        });
    } else {
        const ulElement = document.getElementById('entry-success-list');
        ulElement.innerHTML = `<p id='search-result-empty'>요청된 주문이 없습니다.</p>`;
        const searchResult = await searchResponse.json();
        console.log(searchResult.error);
    }
});

// 엑셀
document.getElementById('download-btn').addEventListener('click', async () => {
    const workbook = XLSX.utils.book_new();
    const datas = orders.map(order => { 
        return {
            '주문일자': order.order_date.substring(0, 10),
            '제품명': order.product_name,
            '수량': order.quantity,
            '옵션': order.standard,
            '병원명': order.hospital_name,
            '연락처': order.call_num,
            '이메일': order.email,
            '문의사항': order.details
        }
    });
    const worksheet = XLSX.utils.json_to_sheet(datas);
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Orders');
    XLSX.writeFile(workbook, 'order-list.xlsx');
});

// 주문 삭제
document.getElementById('delete-btn').addEventListener('click', async () => {
    const orderCheckboxes = document.querySelectorAll('#order-checkbox');
    const ids = [];

    for(const checkbox of orderCheckboxes) {
        if(checkbox.checked) {
            ids.push({order_id: checkbox.value});
        }
    }

    if(ids.length === 0) {
        alert('삭제할 주문을 선택해주세요.');
        return;
    } else {
        const deleteResponse = await fetch('/api/product/delete-orders', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(ids),
        });

        if(deleteResponse.ok) {
            alert('주문이 삭제되었습니다.');
            window.location.reload();
        } else {
            const deleteResult = await deleteResponse.json();
            console.log(deleteResult.error);
        }
    }
});

