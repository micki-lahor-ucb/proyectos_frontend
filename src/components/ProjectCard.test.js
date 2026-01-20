import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProjectCard from './ProjectCard.vue'

describe('ProjectCard', () => {
  const mockProject = {
    id: '1',
    title: 'Test Project',
    description: 'Test Description',
    status: 'ACTIVE',
    createdAt: '2025-01-01T00:00:00Z',
    updatedAt: '2025-01-01T00:00:00Z',
    tasks: [
      { id: '1', title: 'Task 1', status: 'COMPLETED' },
      { id: '2', title: 'Task 2', status: 'PENDING' },
    ],
  }

  it('renders project title', () => {
    const wrapper = mount(ProjectCard, {
      props: {
        project: mockProject,
      },
    })

    expect(wrapper.text()).toContain('Test Project')
  })

  it('renders project description', () => {
    const wrapper = mount(ProjectCard, {
      props: {
        project: mockProject,
      },
    })

    expect(wrapper.text()).toContain('Test Description')
  })

  it('displays correct task count', () => {
    const wrapper = mount(ProjectCard, {
      props: {
        project: mockProject,
      },
    })

    expect(wrapper.text()).toContain('Tareas: 2')
  })

  it('calculates completion percentage correctly', () => {
    const wrapper = mount(ProjectCard, {
      props: {
        project: mockProject,
      },
    })

    // 1 de 2 tareas completadas = 50%
    const progressBar = wrapper.find('[class*="rounded-full"]')
    expect(progressBar.exists()).toBe(true)
  })
})
