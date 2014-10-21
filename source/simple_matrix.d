module simple_matrix;

import core.stdc.stdlib;


struct Vector(T)
{
	T* ptr;
	size_t length;
	ptrdiff_t shift;

	inout(typeof(this)) save() inout @property
	{
		return this;
	}

	size_t opDollar(size_t pos : 1)()
	{
		return length;
	}

	ref inout(T) front() inout @property
	in{
		assert(length);
	}
	body{
		return ptr[0];
	}

	void popFront()
	in{
		assert(length);
	}
	body{
		 ptr += shift;
		 length--;
	}

	bool empty() const @property
	{
		return length == 0;
	}

	ref inout(T) opIndex(size_t index) inout @property
	in {
		assert(index < length);
	}
	body {
		return ptr[shift*index];
	}
}


struct Matrix(T)
{
	T* ptr;
	size_t height;
	size_t width;	
	ptrdiff_t shift;

	inout(Vector!T) column(size_t index) inout
	in
	{
		assert(index < width);
	}
	body
	{
		return typeof(return)(ptr+index, height, shift);
	}


	inout(Transposed!T) transposed() inout
	{
		return typeof(return)(this);
	}


	this(size_t height, size_t width) inout
	{
		this(height, width, width);
	}


	this(inout(T)* ptr, size_t height, size_t width) inout
	{
		this(ptr, height, width, width);
	}


	this(size_t height, size_t width, size_t shift) inout
	{
		this(new inout(T)[height * shift].ptr, height, width, shift);
	}


	this(inout(T)* ptr, size_t height, size_t width, size_t shift) inout
	{
		this.ptr = ptr;
		this.height = height;
		this.width = width;
		this.shift = shift;
	}


	inout(T)[] opIndex(size_t heightI) inout
	in {
		assert(heightI < height);
	}
	body {
		auto l = heightI * shift;
		return ptr[l .. l + width];
	}


	auto ref opIndex(size_t heightI, size_t widthI) inout
	in {
		assert(heightI < height);
		assert(widthI < width);		
	}
	body {
		return ptr[heightI * shift + widthI];
	}


	inout(typeof(this)) opSlice(size_t lb, size_t rb) inout
	in {
		assert(lb <= rb);
		assert(rb < height);
	}
	body {
		return typeof(return)(ptr + shift * lb, rb - lb, width, shift);
	}


	auto ref opSlice(size_t heightI, size_t widthI)
	in {
		assert(heightI < height);
		assert(widthI < width);		
	}
	body {
		return ptr[heightI * shift + widthI];
	}

	T[] array()
	{
		return ptr[0..height * width];
	}


	inout(T)[] front() inout
	{
		assert(height);
		return ptr[0..width];
	}


	void popFront()
	in{ assert(height); }
	body {
		ptr += shift;
		height--;
	}


	void popFrontN(size_t n)
	in{ assert(height >= n); }
	body {
		ptr += shift*n;
		height -= n;
	}


	inout(T)[] back() inout
	{
		assert(height);
		return (ptr+height-1)[0..width];
	}


	void popBack()
	in{ assert(height); }
	body {
		height--;
	}


	void popBackN(size_t n)
	in{ assert(height >= n); }
	body {
		height -= n;
	}


	bool empty() const 
	{
		return length == 0;
	}


	size_t length() const 
	{
		return height;
	}

	size_t opDollar() const
	{
		return length;
	}


	T[][] arrays() 
	{
		auto r = new T[][height];
		foreach(i, ref e; r)
		{
			const l = i * width;
			e = ptr[l..l+width];
		}
		return r;
	}


	auto transpose() const
	{
		import std.traits : Unqual;
		auto m = Matrix!(Unqual!T)(width, height);
		size_t i;
		foreach(row; cast(Matrix!(Unqual!T))this)
		{
			foreach(j, e; row)
			{
				m[j, i] = e;
			}
			i++;
		}
		
		return m;
	}


	inout(T)* ptrEnd() inout
	{
		return ptr+height*shift;
	}
}


struct Transposed(T)
{
	Matrix!T matrix;

	size_t width() const @property
	{
		return matrix.height;
	}

	size_t height() const @property
	{
		return matrix.width;
	}
	
	inout(Matrix!T) transposed() inout
	{
		return matrix;
	}
	
	inout(T)[] column(size_t index) inout
	{
		return matrix[index];
	}
	
	inout(Vector!T) opIndex(size_t index)  inout
	{
		return matrix.column(index);
	}

	auto ref opIndex(size_t index1, size_t index2) inout
	{
		return matrix[index2, index1];
	}

	inout(Vector!T) front() inout
	{
		assert(!empty);
		return matrix.column(0);
	}

	bool empty() const 
	{
		return length == 0;
	}

	void popFront()
	in{ assert(matrix.width); }
	body {
		matrix.ptr++;
		matrix.width--;
	}


	void popFrontN(size_t n)
	in{ assert(matrix.width >= n); }
	body {
		matrix.ptr += n;
		matrix.width -= n;
	}


	size_t length() const 
	{
		return matrix.width;
	}
}


unittest {
	alias M = Matrix!double;
	alias T = Transposed!double;
	alias V = Vector!double;
}
