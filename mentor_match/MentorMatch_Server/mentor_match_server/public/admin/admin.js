
const BASE_URL = 'http://localhost:3000/api';

function getToken() {
    return localStorage.getItem('adminToken');
}

function checkAuth() {
    const token = getToken();
    if (!token) {
        window.location.href = 'index.html'; 
    }
}

async function fetchAPI(endpoint, method = 'GET', body = null) {
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getToken()}`
    };

    const options = { method, headers };
    if (body) options.body = JSON.stringify(body);

    try {
        const response = await fetch(`${BASE_URL}${endpoint}`, options);
        if (response.status === 401 || response.status === 403) {
            alert("Phiên đăng nhập hết hạn hoặc không có quyền!");
            window.location.href = 'index.html';
            return null;
        }
        return await response.json();
    } catch (error) {
        console.error("API Error:", error);
        alert("Lỗi kết nối Server!");
        return null;
    }
}

function logout() {
    localStorage.removeItem('adminToken');
    window.location.href = 'index.html';
}