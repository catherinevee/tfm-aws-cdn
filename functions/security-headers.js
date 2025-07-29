function handler(event) {
    var response = event.response;
    var headers = response.headers;
    
    // Security Headers
    headers['strict-transport-security'] = { value: 'max-age=31536000; includeSubDomains; preload' };
    headers['x-content-type-options'] = { value: 'nosniff' };
    headers['x-frame-options'] = { value: 'DENY' };
    headers['x-xss-protection'] = { value: '1; mode=block' };
    headers['referrer-policy'] = { value: 'strict-origin-when-cross-origin' };
    headers['content-security-policy'] = { value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none';" };
    headers['permissions-policy'] = { value: 'camera=(), microphone=(), geolocation=(), payment=()' };
    
    // Performance Headers
    headers['cache-control'] = { value: 'public, max-age=31536000, immutable' };
    
    return response;
} 