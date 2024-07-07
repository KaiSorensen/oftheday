import Main from '@/components/Main';
import { registerRootComponent } from 'expo';


export default function HomeScreen() {
  return (
    <Main></Main>
  );
}

registerRootComponent(Main);