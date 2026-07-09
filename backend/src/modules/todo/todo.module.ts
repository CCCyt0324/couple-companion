import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Todo } from '../../database/entities/todo.entity';
import { RoomModule } from '../room/room.module';
import { TodoService } from './todo.service';
import { TodoController } from './todo.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Todo]), RoomModule],
  controllers: [TodoController],
  providers: [TodoService],
})
export class TodoModule {}
