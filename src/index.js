#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const API_URL = process.env.SESSION_MEMORY_API_URL || 'http://13.158.83.99:4000';
const DEFAULT_USER_ID = process.env.DEFAULT_USER_ID || 'wanxin';
const DEFAULT_PLATFORM = process.env.DEFAULT_PLATFORM || 'cursor';

class SessionMemoryMCP {
  constructor() {
    this.server = new Server(
      { name: 'session-memory', version: '1.0.0' },
      { capabilities: { tools: {} } }
    );
    this.setupHandlers();
  }

  setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'session_memory_ensure',
          description: '确保任务存在并创建会话',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string', description: '任务ID' },
              platform: { type: 'string', description: '平台', default: DEFAULT_PLATFORM },
              scope: { type: 'string', description: '任务范围' },
              content: { type: 'string', description: '任务内容' }
            },
            required: ['task_id', 'platform']
          }
        },
        {
          name: 'session_memory_update',
          description: '更新会话消息',
          inputSchema: {
            type: 'object',
            properties: {
              session_id: { type: 'string', description: '会话ID' },
              role: { type: 'string', description: '角色', enum: ['user', 'assistant'] },
              content: { type: 'string', description: '消息内容' }
            },
            required: ['session_id', 'role', 'content']
          }
        },
        {
          name: 'session_memory_context',
          description: '获取任务上下文',
          inputSchema: {
            type: 'object',
            properties: {
              task_id: { type: 'string', description: '任务ID' },
              max_messages: { type: 'number', description: '最大消息数', default: 20 }
            },
            required: ['task_id']
          }
        },
        {
          name: 'session_memory_end',
          description: '结束会话',
          inputSchema: {
            type: 'object',
            properties: {
              session_id: { type: 'string', description: '会话ID' }
            },
            required: ['session_id']
          }
        }
      ]
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) =>
      this.handleToolCall(request)
    );
  }

  async handleToolCall(request) {
    const { name, arguments: args } = request.params;

    try {
      let result;
      
      switch (name) {
        case 'session_memory_ensure':
          result = await this.ensureTask(args);
          break;
        case 'session_memory_update':
          result = await this.updateSession(args);
          break;
        case 'session_memory_context':
          result = await this.getContext(args);
          break;
        case 'session_memory_end':
          result = await this.endSession(args);
          break;
        default:
          throw new Error(`Unknown tool: ${name}`);
      }

      return {
        content: [{ type: 'text', text: JSON.stringify(result, null, 2) }]
      };
    } catch (error) {
      console.error(`Tool execution failed: ${name}`, error);
      throw error;
    }
  }

  async ensureTask(args) {
    const response = await axios.post(`${API_URL}/api/tasks/match`, {
      user_id: DEFAULT_USER_ID,
      platform: args.platform || DEFAULT_PLATFORM,
      workspace_path: args.scope || '/default',
      message: args.content || 'New task'
    });
    
    const taskData = response.data.data;
    
    // 创建会话
    const sessionResponse = await axios.post(`${API_URL}/api/sessions`, {
      task_id: taskData.task.task_id,
      platform: args.platform || DEFAULT_PLATFORM
    });
    
    return {
      success: true,
      task_id: taskData.task.task_id,
      session_id: sessionResponse.data.data.session_id,
      message: 'Task ensured and session created'
    };
  }

  async updateSession(args) {
    const response = await axios.post(
      `${API_URL}/api/sessions/${args.session_id}/messages`,
      {
        role: args.role,
        content: args.content,
        metadata: {}
      }
    );
    
    return response.data;
  }

  async getContext(args) {
    const response = await axios.get(
      `${API_URL}/api/tasks/${args.task_id}/context`,
      { params: { max_messages: args.max_messages || 20 } }
    );
    
    return response.data;
  }

  async endSession(args) {
    const response = await axios.put(
      `${API_URL}/api/sessions/${args.session_id}/end`,
      {}
    );
    
    return response.data;
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('✅ Session Memory MCP Client started');
    console.error(`📍 API URL: ${API_URL}`);
  }
}

const mcp = new SessionMemoryMCP();
mcp.start().catch(console.error);

