"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WorkflowSanitizer = void 0;
const crypto_1 = require("crypto");
class WorkflowSanitizer {
    static sanitizeWorkflow(workflow) {
        const sanitized = JSON.parse(JSON.stringify(workflow));
        if (sanitized.nodes && Array.isArray(sanitized.nodes)) {
            sanitized.nodes = sanitized.nodes.map((node) => this.sanitizeNode(node));
        }
        if (sanitized.connections) {
            sanitized.connections = this.sanitizeConnections(sanitized.connections);
        }
        delete sanitized.settings?.errorWorkflow;
        delete sanitized.staticData;
        delete sanitized.pinData;
        delete sanitized.credentials;
        delete sanitized.sharedWorkflows;
        delete sanitized.ownedBy;
        delete sanitized.createdBy;
        delete sanitized.updatedBy;
        const nodeTypes = sanitized.nodes?.map((n) => n.type) || [];
        const uniqueNodeTypes = [...new Set(nodeTypes)];
        const hasTrigger = nodeTypes.some((type) => type.includes('trigger') || type.includes('webhook'));
        const hasWebhook = nodeTypes.some((type) => type.includes('webhook'));
        const nodeCount = sanitized.nodes?.length || 0;
        let complexity = 'simple';
        if (nodeCount > 20) {
            complexity = 'complex';
        }
        else if (nodeCount > 10) {
            complexity = 'medium';
        }
        const workflowStructure = JSON.stringify({
            nodeTypes: uniqueNodeTypes.sort(),
            connections: sanitized.connections
        });
        const workflowHash = (0, crypto_1.createHash)('sha256')
            .update(workflowStructure)
            .digest('hex')
            .substring(0, 16);
        return {
            nodes: sanitized.nodes || [],
            connections: sanitized.connections || {},
            nodeCount,
            nodeTypes: uniqueNodeTypes,
            hasTrigger,
            hasWebhook,
            complexity,
            workflowHash
        };
    }
    static sanitizeNode(node) {
        const sanitized = { ...node };
        delete sanitized.credentials;
        if (sanitized.parameters) {
            sanitized.parameters = this.sanitizeObject(sanitized.parameters);
        }
        return sanitized;
    }
    static sanitizeObject(obj) {
        if (!obj || typeof obj !== 'object') {
            return obj;
        }
        if (Array.isArray(obj)) {
            return obj.map(item => this.sanitizeObject(item));
        }
        const sanitized = {};
        for (const [key, value] of Object.entries(obj)) {
            if (this.isSensitiveField(key)) {
                sanitized[key] = '[REDACTED]';
                continue;
            }
            if (typeof value === 'object' && value !== null) {
                sanitized[key] = this.sanitizeObject(value);
            }
            else if (typeof value === 'string') {
                sanitized[key] = this.sanitizeString(value, key);
            }
            else {
                sanitized[key] = value;
            }
        }
        return sanitized;
    }
    static sanitizeString(value, fieldName) {
        if (value.includes('/webhook/') || value.includes('/hook/')) {
            return 'https://[webhook-url]';
        }
        let sanitized = value;
        for (const pattern of this.SENSITIVE_PATTERNS) {
            if (pattern.toString().includes('webhook')) {
                continue;
            }
            sanitized = sanitized.replace(pattern, '[REDACTED]');
        }
        if (fieldName.toLowerCase().includes('url') ||
            fieldName.toLowerCase().includes('endpoint')) {
            if (sanitized.startsWith('http://') || sanitized.startsWith('https://')) {
                if (sanitized.includes('[REDACTED]')) {
                    return '[REDACTED]';
                }
                const urlParts = sanitized.split('/');
                if (urlParts.length > 2) {
                    urlParts[2] = '[domain]';
                    sanitized = urlParts.join('/');
                }
            }
        }
        return sanitized;
    }
    static isSensitiveField(fieldName) {
        const lowerFieldName = fieldName.toLowerCase();
        return this.SENSITIVE_FIELDS.some(sensitive => lowerFieldName.includes(sensitive.toLowerCase()));
    }
    static sanitizeConnections(connections) {
        if (!connections || typeof connections !== 'object') {
            return connections;
        }
        const sanitized = {};
        for (const [nodeId, nodeConnections] of Object.entries(connections)) {
            if (typeof nodeConnections === 'object' && nodeConnections !== null) {
                sanitized[nodeId] = {};
                for (const [connType, connArray] of Object.entries(nodeConnections)) {
                    if (Array.isArray(connArray)) {
                        sanitized[nodeId][connType] = connArray.map((conns) => {
                            if (Array.isArray(conns)) {
                                return conns.map((conn) => ({
                                    node: conn.node,
                                    type: conn.type,
                                    index: conn.index
                                }));
                            }
                            return conns;
                        });
                    }
                    else {
                        sanitized[nodeId][connType] = connArray;
                    }
                }
            }
            else {
                sanitized[nodeId] = nodeConnections;
            }
        }
        return sanitized;
    }
    static generateWorkflowHash(workflow) {
        const sanitized = this.sanitizeWorkflow(workflow);
        return sanitized.workflowHash;
    }
}
exports.WorkflowSanitizer = WorkflowSanitizer;
WorkflowSanitizer.SENSITIVE_PATTERNS = [
    /https?:\/\/[^\s/]+\/webhook\/[^\s]+/g,
    /https?:\/\/[^\s/]+\/hook\/[^\s]+/g,
    /sk-[a-zA-Z0-9]{16,}/g,
    /Bearer\s+[^\s]+/gi,
    /[a-zA-Z0-9_-]{20,}/g,
    /token['":\s]+[^,}]+/gi,
    /apikey['":\s]+[^,}]+/gi,
    /api_key['":\s]+[^,}]+/gi,
    /secret['":\s]+[^,}]+/gi,
    /password['":\s]+[^,}]+/gi,
    /credential['":\s]+[^,}]+/gi,
    /https?:\/\/[^:]+:[^@]+@[^\s/]+/g,
    /wss?:\/\/[^:]+:[^@]+@[^\s/]+/g,
];
WorkflowSanitizer.SENSITIVE_FIELDS = [
    'apiKey',
    'api_key',
    'token',
    'secret',
    'password',
    'credential',
    'auth',
    'authorization',
    'webhook',
    'webhookUrl',
    'url',
    'endpoint',
    'host',
    'server',
    'database',
    'connectionString',
    'privateKey',
    'publicKey',
    'certificate',
];
//# sourceMappingURL=workflow-sanitizer.js.map