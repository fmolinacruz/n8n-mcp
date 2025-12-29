"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toolsDocumentation = void 0;
const discovery_1 = require("./discovery");
const configuration_1 = require("./configuration");
const validation_1 = require("./validation");
const templates_1 = require("./templates");
const system_1 = require("./system");
const guides_1 = require("./guides");
const workflow_management_1 = require("./workflow_management");
exports.toolsDocumentation = {
    tools_documentation: system_1.toolsDocumentationDoc,
    n8n_diagnostic: system_1.n8nDiagnosticDoc,
    n8n_health_check: system_1.n8nHealthCheckDoc,
    n8n_list_available_tools: system_1.n8nListAvailableToolsDoc,
    ai_agents_guide: guides_1.aiAgentsGuide,
    search_nodes: discovery_1.searchNodesDoc,
    list_nodes: discovery_1.listNodesDoc,
    list_ai_tools: discovery_1.listAiToolsDoc,
    get_database_statistics: discovery_1.getDatabaseStatisticsDoc,
    get_node_essentials: configuration_1.getNodeEssentialsDoc,
    get_node_info: configuration_1.getNodeInfoDoc,
    get_node_documentation: configuration_1.getNodeDocumentationDoc,
    search_node_properties: configuration_1.searchNodePropertiesDoc,
    get_node_as_tool_info: configuration_1.getNodeAsToolInfoDoc,
    get_property_dependencies: configuration_1.getPropertyDependenciesDoc,
    validate_node_minimal: validation_1.validateNodeMinimalDoc,
    validate_node_operation: validation_1.validateNodeOperationDoc,
    validate_workflow: validation_1.validateWorkflowDoc,
    validate_workflow_connections: validation_1.validateWorkflowConnectionsDoc,
    validate_workflow_expressions: validation_1.validateWorkflowExpressionsDoc,
    list_tasks: templates_1.listTasksDoc,
    list_node_templates: templates_1.listNodeTemplatesDoc,
    get_template: templates_1.getTemplateDoc,
    search_templates: templates_1.searchTemplatesDoc,
    search_templates_by_metadata: templates_1.searchTemplatesByMetadataDoc,
    get_templates_for_task: templates_1.getTemplatesForTaskDoc,
    n8n_create_workflow: workflow_management_1.n8nCreateWorkflowDoc,
    n8n_get_workflow: workflow_management_1.n8nGetWorkflowDoc,
    n8n_get_workflow_details: workflow_management_1.n8nGetWorkflowDetailsDoc,
    n8n_get_workflow_structure: workflow_management_1.n8nGetWorkflowStructureDoc,
    n8n_get_workflow_minimal: workflow_management_1.n8nGetWorkflowMinimalDoc,
    n8n_update_full_workflow: workflow_management_1.n8nUpdateFullWorkflowDoc,
    n8n_update_partial_workflow: workflow_management_1.n8nUpdatePartialWorkflowDoc,
    n8n_delete_workflow: workflow_management_1.n8nDeleteWorkflowDoc,
    n8n_list_workflows: workflow_management_1.n8nListWorkflowsDoc,
    n8n_validate_workflow: workflow_management_1.n8nValidateWorkflowDoc,
    n8n_autofix_workflow: workflow_management_1.n8nAutofixWorkflowDoc,
    n8n_trigger_webhook_workflow: workflow_management_1.n8nTriggerWebhookWorkflowDoc,
    n8n_get_execution: workflow_management_1.n8nGetExecutionDoc,
    n8n_list_executions: workflow_management_1.n8nListExecutionsDoc,
    n8n_delete_execution: workflow_management_1.n8nDeleteExecutionDoc
};
//# sourceMappingURL=index.js.map