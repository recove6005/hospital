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

    }
});

const getOrdersResponse = await fetch('/api/product/get-all-orders');
if(getOrdersResponse.ok) {
    const entryInputContainer = document.getElementById('entry-container');
    entryInputContainer.style.display = 'none';

    const entrySuccessContainer = document.getElementById('entry-success-container');
    entrySuccessContainer.style.display = 'block';

    const ulElement = document.getElementById('entry-success-list');
    orders = await getOrdersResponse.json();
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

document.getElementById('search-btn').addEventListener('click', async () => {
    const startDate = document.getElementById('search-start-date').value;
    const endDate = document.getElementById('search-end-date').value;

    console.log(startDate, endDate);
});

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
