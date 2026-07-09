import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Todo } from '../../database/entities/todo.entity';

@Injectable()
export class TodoService {
  constructor(@InjectRepository(Todo) private todoRepo: Repository<Todo>) {}

  async list(roomId: number): Promise<Todo[]> {
    return this.todoRepo.find({
      where: { roomId }, order: { createdAt: 'DESC' },
    });
  }

  async create(roomId: number, createdBy: number, content: string, deadline?: Date): Promise<Todo> {
    const todo = this.todoRepo.create({ roomId, createdBy, content, deadline });
    return this.todoRepo.save(todo);
  }

  async toggle(id: number): Promise<Todo> {
    const todo = await this.todoRepo.findOne({ where: { id } });
    if (!todo) throw new Error('待办不存在');
    todo.status = todo.status === 'done' ? 'pending' : 'done';
    return this.todoRepo.save(todo);
  }

  async delete(id: number): Promise<void> {
    await this.todoRepo.delete(id);
  }
}
