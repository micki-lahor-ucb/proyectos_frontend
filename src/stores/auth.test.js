import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from './auth'
import apiClient from '../services/api'

// Mock del apiClient
vi.mock('../services/api', () => ({
  default: {
    post: vi.fn(),
    interceptors: {
      request: { use: vi.fn() },
      response: { use: vi.fn() },
    },
  },
}))

describe('Auth Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    localStorage.clear()
    vi.clearAllMocks()
  })

  it('should initialize with null user and token', () => {
    const authStore = useAuthStore()
    expect(authStore.user).toBeNull()
    expect(authStore.token).toBeNull()
    expect(authStore.isAuthenticated).toBe(false)
  })

  it('should login successfully', async () => {
    const mockResponse = {
      data: {
        access_token: 'test-token',
        user: {
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
        },
      },
    }

    apiClient.post.mockResolvedValue(mockResponse)

    const authStore = useAuthStore()
    const result = await authStore.login({
      email: 'test@example.com',
      password: 'password123',
    })

    expect(result).toBe(true)
    expect(authStore.token).toBe('test-token')
    expect(authStore.user.email).toBe('test@example.com')
    expect(authStore.isAuthenticated).toBe(true)
    expect(localStorage.getItem('token')).toBe('test-token')
  })

  it('should handle login failure', async () => {
    apiClient.post.mockRejectedValue({
      response: {
        data: {
          message: 'Invalid credentials',
        },
      },
    })

    const authStore = useAuthStore()
    const result = await authStore.login({
      email: 'test@example.com',
      password: 'wrong-password',
    })

    expect(result).toBe(false)
    expect(authStore.token).toBeNull()
    expect(authStore.error).toBe('Invalid credentials')
  })

  it('should logout and clear storage', () => {
    const authStore = useAuthStore()
    authStore.token = 'test-token'
    authStore.user = { id: '1', email: 'test@example.com' }
    localStorage.setItem('token', 'test-token')
    localStorage.setItem('user', JSON.stringify({ id: '1' }))

    authStore.logout()

    expect(authStore.token).toBeNull()
    expect(authStore.user).toBeNull()
    expect(localStorage.getItem('token')).toBeNull()
    expect(localStorage.getItem('user')).toBeNull()
  })
})
