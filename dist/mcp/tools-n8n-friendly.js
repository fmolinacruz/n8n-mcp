"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.n8nFriendlyDescriptions = void 0;
exports.makeToolsN8nFriendly = makeToolsN8nFriendly;
exports.n8nFriendlyDescriptions = {
    validate_node_operation: {
        description: 'Validate n8n node. ALWAYS pass two parameters: nodeType (string) and config (object). Example call: {"nodeType": "nodes-base.slack", "config": {"resource": "channel", "operation": "create"}}',
        params: {
            nodeType: 'String value like "nodes-base.slack"',
            config: 'Object value like {"resource": "channel", "operation": "create"} or empty object {}',
            profile: 'Optional string: "minimal" or "runtime" or "ai-friendly" or "strict"'
        }
    },
    validate_node_minimal: {
        description: 'Check required fields. MUST pass: nodeType (string) and config (object). Example: {"nodeType": "nodes-base.webhook", "config": {}}',
        params: {
            nodeType: 'String like "nodes-base.webhook"',
            config: 'Object, use {} for empty'
        }
    },
    search_nodes: {
        description: 'Search nodes. Pass query (string). Example: {"query": "webhook"}',
        params: {
            query: 'String keyword like "webhook" or "database"',
            limit: 'Optional number, default 20'
        }
    },
    get_node_info: {
        description: 'Get node details. Pass nodeType (string). Example: {"nodeType": "nodes-base.httpRequest"}',
        params: {
            nodeType: 'String with prefix like "nodes-base.httpRequest"'
        }
    },
    get_node_essentials: {
        description: 'Get node basics. Pass nodeType (string). Example: {"nodeType": "nodes-base.slack"}',
        params: {
            nodeType: 'String with prefix like "nodes-base.slack"'
        }
    },
    get_node_for_task: {
        description: 'Find node for task. Pass task (string). Example: {"task": "send_http_request"}',
        params: {
            task: 'String task name like "send_http_request"'
        }
    },
    list_tasks: {
        description: 'List tasks by category. Pass category (string). Example: {"category": "HTTP/API"}',
        params: {
            category: 'String: "HTTP/API" or "Webhooks" or "Database" or "AI/LangChain" or "Data Processing" or "Communication"'
        }
    },
    validate_workflow: {
        description: 'Validate workflow. Pass workflow object. MUST have: {"workflow": {"nodes": [array of node objects], "connections": {object with node connections}}}. Each node needs: name, type, typeVersion, position.',
        params: {
            workflow: 'Object with two required fields: nodes (array) and connections (object). Example: {"nodes": [{"name": "Webhook", "type": "n8n-nodes-base.webhook", "typeVersion": 2, "position": [250, 300], "parameters": {}}], "connections": {}}',
            options: 'Optional object. Example: {"validateNodes": true, "profile": "runtime"}'
        }
    },
    validate_workflow_connections: {
        description: 'Validate workflow connections only. Pass workflow object. Example: {"workflow": {"nodes": [...], "connections": {}}}',
        params: {
            workflow: 'Object with nodes array and connections object. Minimal example: {"nodes": [{"name": "Webhook"}], "connections": {}}'
        }
    },
    validate_workflow_expressions: {
        description: 'Validate n8n expressions in workflow. Pass workflow object. Example: {"workflow": {"nodes": [...], "connections": {}}}',
        params: {
            workflow: 'Object with nodes array and connections object containing n8n expressions like {{ $json.data }}'
        }
    },
    get_property_dependencies: {
        description: 'Get field dependencies. Pass nodeType (string) and optional config (object). Example: {"nodeType": "nodes-base.httpRequest", "config": {}}',
        params: {
            nodeType: 'String like "nodes-base.httpRequest"',
            config: 'Optional object, use {} for empty'
        }
    },
    get_node_as_tool_info: {
        description: 'Get AI tool usage. Pass nodeType (string). Example: {"nodeType": "nodes-base.slack"}',
        params: {
            nodeType: 'String with prefix like "nodes-base.slack"'
        }
    },
    search_templates: {
        description: 'Search workflow templates. Pass query (string). Example: {"query": "chatbot"}',
        params: {
            query: 'String keyword like "chatbot" or "webhook"',
            limit: 'Optional number, default 20'
        }
    },
    get_template: {
        description: 'Get template by ID. Pass templateId (number). Example: {"templateId": 1234}',
        params: {
            templateId: 'Number ID like 1234'
        }
    },
    tools_documentation: {
        description: 'Get tool docs. Pass optional depth (string). Example: {"depth": "essentials"} or {}',
        params: {
            depth: 'Optional string: "essentials" or "overview" or "detailed"',
            topic: 'Optional string topic name'
        }
    }
};
function makeToolsN8nFriendly(tools) {
    return tools.map(tool => {
        const toolName = tool.name;
        const friendlyDesc = exports.n8nFriendlyDescriptions[toolName];
        if (friendlyDesc) {
            const updatedTool = { ...tool };
            updatedTool.description = friendlyDesc.description;
            if (tool.inputSchema?.properties) {
                updatedTool.inputSchema = {
                    ...tool.inputSchema,
                    properties: { ...tool.inputSchema.properties }
                };
                Object.keys(updatedTool.inputSchema.properties).forEach(param => {
                    if (friendlyDesc.params[param]) {
                        updatedTool.inputSchema.properties[param] = {
                            ...updatedTool.inputSchema.properties[param],
                            description: friendlyDesc.params[param]
                        };
                    }
                });
            }
            return updatedTool;
        }
        return tool;
    });
}
//# sourceMappingURL=tools-n8n-friendly.js.map